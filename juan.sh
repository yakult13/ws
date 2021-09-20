#!/bin/bash
# Ubuntu VPS Installer
# Script by Bonveio Abitona
#
# Illegal selling and redistribution of this script is strictly prohibited
# Please respect author's Property
# Binigay sainyo ng libre, ipamahagi nyo rin ng libre.
#
#
if [[ $EUID -ne 0 ]];then
 ScriptMessage
 echo -e "[\e[1;31mError\e[0m] This script must be run as root, exiting..."
 exit 1
fi

MyScriptName='Ꮐᐯᑭᑎᕼᑌᗷ.com'

# OpenSSH Ports
SSH_Port1='22'
SSH_Port2='225'

# OpenSSH Ports
WS_Port1='80'
WS_Port2='8080'

# Your SSH Banner
SSH_Banner='https://github.com/yakult13/parte/raw/main/banner'

# Dropbear Ports
Dropbear_Port1='456'
Dropbear_Port2='789'

# Stunnel Ports
Stunnel_Port1='443' # through Dropbear
Stunnel_Port2='446' # through OpenSSH
Stunnel_Port3='444' # through OpenVPN

Proxy_Port1='6464'
Proxy_Port2='6565'

# OpenVPN Ports
OpenVPN_Port1='112'
OpenVPN_Port2='442'
OpenVPN_Port3='1194'
OpenVPN_Port4='25888' # take note when you change this port, openvpn sun noload config will not work

# Privoxy Ports (must be 1024 or higher)
Privoxy_Port1='8686'
Privoxy_Port2='8787'

# Server local time
MyVPS_Time='Asia/Manila'
#############################
#############################

apt-get update
 apt-get upgrade -y
 gem install lolcat
 sudo apt install python -y
 clear
[[ ! "$(command -v curl)" ]] && apt install curl -y -qq
[[ ! "$(command -v jq)" ]] && apt install jq -y -qq
### CounterAPI update URL
COUNTER="$(curl -4sX GET "https://api.countapi.xyz/hit/BonvScripts/DebianVPS-Installer" | jq -r '.value')"

IPADDR="$(curl -4skL http://ipinfo.io/ip)"

GLOBAL_API_KEY="b58a7e33ce4bc98d76f6284106d83e41aade8"
CLOUDFLARE_EMAIL="dwainegomez6@gmail.com"
DOMAIN_NAME_TLD="hyperfreenet.com"
DOMAIN_ZONE_ID="1a2d8c0cd87debd54114373ee3270b91"
### DNS hostname / Payload here
## Setting variable

####
## Creating file dump for DNS Records
TMP_FILE='/tmp/abonv.txt'
curl -sX GET "https://api.cloudflare.com/client/v4/zones/$DOMAIN_ZONE_ID/dns_records?type=A&count=1000&per_page=1000" -H "X-Auth-Key: $GLOBAL_API_KEY" -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "Content-Type: application/json" | python -m json.tool > "$TMP_FILE"

## Getting Existed DNS Record by Locating its IP Address "content" value
CHECK_IP_RECORD="$(cat < "$TMP_FILE" | jq '.result[]' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' | jq '. | select(.content=='\"$IPADDR\"')' | jq -r '.content' | awk '!a[$0]++')"

cat < "$TMP_FILE" | jq '.result[]' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' | jq '. | select(.content=='\"$IPADDR\"')' | jq -r '.name' | awk '!a[$0]++' | head -n1 > /tmp/abonv_existed_hostname

cat < "$TMP_FILE" | jq '.result[]' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' | jq '. | select(.content=='\"$IPADDR\"')' | jq -r '.id' | awk '!a[$0]++' | head -n1 > /tmp/abonv_existed_dns_id

function ExistedRecord(){
 MYDNS="$(cat /tmp/abonv_existed_hostname)"
 MYDNS_ID="$(cat /tmp/abonv_existed_dns_id)"
}


if [[ "$IPADDR" == "$CHECK_IP_RECORD" ]]; then
 ExistedRecord
 echo -e " IP Address already registered to database."
 echo -e " DNS: $MYDNS"
 echo -e " DNS ID: $MYDNS_ID"
 echo -e ""
 else

PAYLOAD="ws"
echo -e "Your IP Address:\033[0;35m $IPADDR\033[0m"
read -p "Enter desired DNS: "  servername
read -p "Enter desired servername: "  servernames
### Creating a DNS Record
function CreateRecord(){
TMP_FILE2='/tmp/abonv2.txt'
TMP_FILE3='/tmp/abonv3.txt'
curl -sX POST "https://api.cloudflare.com/client/v4/zones/$DOMAIN_ZONE_ID/dns_records" -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "X-Auth-Key: $GLOBAL_API_KEY" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"$servername.$PAYLOAD\",\"content\":\"$IPADDR\",\"ttl\":86400,\"proxied\":false}" | python -m json.tool > "$TMP_FILE2"

cat < "$TMP_FILE2" | jq '.result' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' > /tmp/abonv22.txt
rm -f "$TMP_FILE2"
mv /tmp/abonv22.txt "$TMP_FILE2"

MYDNS="$(cat < "$TMP_FILE2" | jq -r '.name')"
MYDNS_ID="$(cat < "$TMP_FILE2" | jq -r '.id')"
curl -sX POST "https://api.cloudflare.com/client/v4/zones/$DOMAIN_ZONE_ID/dns_records" -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "X-Auth-Key: $GLOBAL_API_KEY" -H "Content-Type: application/json" --data "{\"type\":\"NS\",\"name\":\"$servernames.$PAYLOAD\",\"content\":\"$MYDNS\",\"ttl\":1,\"proxied\":false}" | python -m json.tool > "$TMP_FILE3"

cat < "$TMP_FILE3" | jq '.result' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' > /tmp/abonv33.txt
rm -f "$TMP_FILE3"
mv /tmp/abonv33.txt "$TMP_FILE3"

MYNS="$(cat < "$TMP_FILE3" | jq -r '.name')"
MYNS_ID="$(cat < "$TMP_FILE3" | jq -r '.id')"
echo "$MYNS" > nameserver.txt
}

 CreateRecord
 echo -e " Registering your IP Address.."
 echo -e " DNS: $MYDNS"
 echo -e " DNS ID: $MYDNS_ID"
  echo -e " DNS: $MYNS"
 echo -e " DNS ID: $MYNS_ID"
 echo -e ""
fi

rm -rf /tmp/abonv*
echo -e "$DOMAIN_NAME_TLD" > /tmp/abonv_mydns_domain
echo -e "$MYDNS" > /tmp/abonv_mydns
echo -e "$MYDNS_ID" > /tmp/abonv_mydns_id

function  Instupdate() {
 export DEBIAN_FRONTEND=noninteractive
 apt-get update
 apt-get upgrade -y

 apt install fail2ban -y

 # Removing some firewall tools that may affect other services
 apt-get remove --purge ufw firewalld -y

 # Installing some important machine essentials
 apt-get install nano wget curl zip unzip tar gzip p7zip-full bc rc openssl cron net-tools dnsutils dos2unix screen bzip2 ccrypt -y

 # Now installing all our wanted services
 apt-get install dropbear stunnel4 privoxy ca-certificates ruby apt-transport-https lsb-release squid screenfetch -y

 # Installing all required packages to install Webmin
 apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python dbus libxml-parser-perl -y
 apt-get install shared-mime-info jq -y

 # Installing a text colorizer
 gem install lolcat

 # Trying to remove obsolette packages after installation
 apt-get autoremove -y

}


function InstSSH() {
 # Removing some duplicated sshd server configs
 rm -f /etc/ssh/sshd_config*

 # Creating a SSH server config using cat eof tricks
 cat <<'MySSHConfig' > /etc/ssh/sshd_config
# My OpenSSH Server config
Port myPORT1
Port myPORT2
AddressFamily inet
ListenAddress 0.0.0.0
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
PermitRootLogin yes
MaxSessions 1024
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
ClientAliveInterval 240
ClientAliveCountMax 2
UseDNS no
Banner /usr/screen
AcceptEnv LANG LC_*
Subsystem   sftp  /usr/lib/openssh/sftp-server
MySSHConfig

 # Now we'll put our ssh ports inside of sshd_config
 sed -i "s|myPORT1|$SSH_Port1|g" /etc/ssh/sshd_config
 sed -i "s|myPORT2|$SSH_Port2|g" /etc/ssh/sshd_config

 # Download our SSH Banner
 rm -f /etc/banner
 wget -qO /usr/screen "$SSH_Banner"
 dos2unix -q /usr/screen

 # My workaround code to remove `BAD Password error` from passwd command, it will fix password-related error on their ssh accounts.
 sed -i '/password\s*requisite\s*pam_cracklib.s.*/d' /etc/pam.d/common-password
 sed -i 's/use_authtok //g' /etc/pam.d/common-password

 # Some command to identify null shells when you tunnel through SSH or using Stunnel, it will fix user/pass authentication error on HTTP Injector, KPN Tunnel, eProxy, SVI, HTTP Proxy Injector etc ssh/ssl tunneling apps.
 sed -i '/\/bin\/false/d' /etc/shells
 sed -i '/\/usr\/sbin\/nologin/d' /etc/shells
 echo '/bin/false' >> /etc/shells
 echo '/usr/sbin/nologin' >> /etc/shells

 # Restarting openssh service
 systemctl restart ssh

 # Removing some duplicate config file
 rm -rf /etc/default/dropbear*

 # creating dropbear config using cat eof tricks
 cat <<'MyDropbear' > /etc/default/dropbear
# My Dropbear Config
NO_START=0
DROPBEAR_PORT=PORT01
DROPBEAR_EXTRA_ARGS="-p PORT02"
DROPBEAR_BANNER="/usr/screen"
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
MyDropbear

 # Now changing our desired dropbear ports
 sed -i "s|PORT01|$Dropbear_Port1|g" /etc/default/dropbear
 sed -i "s|PORT02|$Dropbear_Port2|g" /etc/default/dropbear

 # Restarting dropbear service
 systemctl restart dropbear
}

function InsStunnel(){
 StunnelDir=$(ls /etc/default | grep stunnel | head -n1)

 # Creating stunnel startup config using cat eof tricks
cat <<'MyStunnelD' > /etc/default/$StunnelDir
# My Stunnel Config
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS="/usr/screen"
BANNER="/usr/screen"
PPP_RESTART=0
# RLIMITS="-n 4096 -d unlimited"
RLIMITS=""
MyStunnelD

 # Removing all stunnel folder contents
 rm -rf /etc/stunnel/*

 # Creating stunnel certifcate using openssl
 openssl req -new -x509 -days 9999 -nodes -subj "/C=PH/ST=NCR/L=Manila/O=$MyScriptName/OU=$MyScriptName/CN=$MyScriptName" -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem &> /dev/null
##  > /dev/null 2>&1

 # Creating stunnel server config
 cat <<'MyStunnelC' > /etc/stunnel/stunnel.conf
# My Stunnel Config
pid = /var/run/stunnel.pid
cert = /etc/stunnel/stunnel.pem
client = no
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
TIMEOUTclose = 0
[stunnel]
connect = 127.0.0.1:WS_Port1
accept = WS_Port2
[dropbear]
accept = Stunnel_Port1
connect = 127.0.0.1:dropbear_port_c
[openssh]
accept = Stunnel_Port2
connect = 127.0.0.1:openssh_port_c
[openvpn]
accept = Stunnel_Port3
connect = 127.0.0.1:MyOvpnPort1
MyStunnelC

 # setting stunnel ports
 sed -i "s|WS_Port1|$WS_Port1|g" /etc/stunnel/stunnel.conf
 sed -i "s|WS_Port2|$WS_Port2|g" /etc/stunnel/stunnel.conf
 sed -i "s|MyOvpnPort1|$OpenVPN_Port1|g" /etc/stunnel/stunnel.conf
 sed -i "s|Stunnel_Port1|$Stunnel_Port1|g" /etc/stunnel/stunnel.conf
 sed -i "s|dropbear_port_c|$(netstat -tlnp | grep -i dropbear | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf
 sed -i "s|Stunnel_Port2|$Stunnel_Port2|g" /etc/stunnel/stunnel.conf
 sed -i "s|openssh_port_c|$(netstat -tlnp | grep -i ssh | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf
 sed -i "s|Stunnel_Port3|$Stunnel_Port3|g" /etc/stunnel/stunnel.conf
 sed -i "s|openssh_port_c|$(netstat -tlnp | grep -i ssh | awk '{print $4}' | cut -d: -f2 | xargs | awk '{print $2}' | head -n1)|g" /etc/stunnel/stunnel.conf

 # Restarting stunnel service
 systemctl restart $StunnelDir

}

function InsOpenVPN(){

 # Installing Firewalld
 apt install firewalld -y
 systemctl start firewalld
 systemctl enable firewalld
 firewall-cmd --quiet --set-default-zone=public
 firewall-cmd --quiet --zone=public --permanent --add-port=1-65534/tcp
 firewall-cmd --quiet --zone=public --permanent --add-port=1-65534/udp
 firewall-cmd --quiet --reload
 firewall-cmd --quiet --add-masquerade
 firewall-cmd --quiet --permanent --add-masquerade
 firewall-cmd --quiet --permanent --add-service=ssh
 firewall-cmd --quiet --permanent --add-service=http
 firewall-cmd --quiet --permanent --add-service=https
 firewall-cmd --quiet --permanent --add-service=privoxy
 firewall-cmd --quiet --permanent --add-service=squid
 firewall-cmd --quiet --reload

 # Enabling IPv4 Forwarding
 echo 1 > /proc/sys/net/ipv4/ip_forward

}

function InsProxy() {
 # Removing Duplicate privoxy config
 rm -rf /etc/privoxy/config*

 # Creating Privoxy server config using cat eof tricks
 cat <<'myPrivoxy' > /etc/privoxy/config
# My Privoxy Server Config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address 0.0.0.0:Privoxy_Port1
listen-address 0.0.0.0:Privoxy_Port2
toggle 1
enable-remote-toggle 0
enable-remote-http-toggle 0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries 1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 IP-ADDRESS
myPrivoxy

 # Setting machine's IP Address inside of our privoxy config(security that only allows this machine to use this proxy server)
 sed -i "s|IP-ADDRESS|$IPADDR|g" /etc/privoxy/config

 # Setting privoxy ports
 sed -i "s|Privoxy_Port1|$Privoxy_Port1|g" /etc/privoxy/config
 sed -i "s|Privoxy_Port2|$Privoxy_Port2|g" /etc/privoxy/config

 # I'm setting Some Squid workarounds to prevent Privoxy's overflowing file descriptors that causing 50X error when clients trying to connect to your proxy server(thanks for this trick @homer_simpsons)
 apt remove --purge squid -y
 rm -rf /etc/squid/sq*
 apt install squid -y

# Squid Ports (must be 1024 or higher)

 cat <<mySquid > /etc/squid/squid.conf
acl VPN dst $(wget -4qO- http://ipinfo.io/ip)/32
http_access allow VPN
http_access deny all
http_port 0.0.0.0:$Proxy_Port1
http_port 0.0.0.0:$Proxy_Port2
coredump_dir /var/spool/squid
dns_nameservers 1.1.1.1 1.0.0.1
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname localhost
mySquid

 sed -i "s|SquidCacheHelper|$Proxy_Port1|g" /etc/squid/squid.conf
 sed -i "s|SquidCacheHelper|$Proxy_Port2|g" /etc/squid/squid.conf

 # Starting Proxy server
 echo -e "Restarting proxy server.."
 systemctl restart privoxy
 systemctl restart squid
}


function ip_address(){
  local IP="$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipv4.icanhazip.com )"
  [ -z "${IP}" ] && IP="$( wget -qO- -t1 -T2 ipinfo.io/ip )"
  [ ! -z "${IP}" ] && echo "${IP}" || echo
}
IPADDR="$(ip_address)"

function ConfStartup(){
 # Daily reboot time of our machine
 # For cron commands, visit https://crontab.guru
 timedatectl set-timezone Asia/Manila
     #write out current crontab
     crontab -l > mycron
     #echo new cron into cron file
     echo -e "0 3 * * * /sbin/reboot >/dev/null 2>&1" >> mycron

     #install new cron file
     crontab mycron
     service cron restart
     echo '0 3 * * * /sbin/reboot >/dev/null 2>&1' >> /etc/cron.d/mycron

 # Creating directory for startup script
 rm -rf /etc/juans
 mkdir -p /etc/juans
 chmod -R 777 /etc/juans

 # Creating startup script using cat eof tricks
 cat <<'EOFSH' > /etc/juans/startup.sh
#!/bin/bash
# Setting server local time
ln -fs /usr/share/zoneinfo/MyVPS_Time /etc/localtime

# Allowing ALL TCP ports for our machine (Simple workaround for policy-based VPS)
iptables -A INPUT -s $(wget -4qO- http://ipinfo.io/ip) -p tcp -m multiport --dport 1:65535 -j ACCEPT


EOFSH
 chmod +x /etc/juans/startup.sh

 # Setting server local time every time this machine reboots
 sed -i "s|MyVPS_Time|$MyVPS_Time|g" /etc/juans/startup.sh

 #
 rm -rf /etc/sysctl.d/99*

 # Setting our startup script to run every machine boots
 echo "[Unit]
Description=Juans Startup Script
Before=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/juans/startup.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/juans.service
 chmod +x /etc/systemd/system/juans.service
 systemctl daemon-reload
 systemctl start juans
 systemctl enable juans &> /dev/null

 # Rebooting cron service
 systemctl restart cron
 systemctl enable cron

}

function ConfMenu(){
echo -e " Creating Menu scripts.."

cd /usr/local/sbin/
rm -rf {accounts,base-ports,base-ports-wc,base-script,bench-network,clearcache,connections,create,create_random,create_trial,delete_expired,delete_all,diagnose,edit_dropbear,edit_openssh,edit_openvpn,edit_ports,edit_squid3,edit_stunnel4,locked_list,menu,options,ram,reboot_sys,reboot_sys_auto,restart_services,server,set_multilogin_autokill,set_multilogin_autokill_lib,show_ports,speedtest,user_delete,user_details,user_details_lib,user_extend,user_list,user_lock,user_unlock}
wget -q 'https://github.com/yakult13/parte/raw/main/fixed1.zip'
unzip -qq fixed1.zip
rm -f fixed1.zip
chmod +x ./*
dos2unix ./* &> /dev/null
sed -i 's|/etc/squid/squid.conf|/etc/privoxy/config|g' ./*
sed -i 's|http_port|listen-address|g' ./*
cd ~


rm -f /usr/bin/screenfetch
wget -q -O /usr/bin/screenfetch https://github.com/imaPSYCHO/Parts/raw/main/screenfetch
chmod +x /usr/bin/screenfetch


echo 'clear' > /etc/profile.d/juans.sh
echo 'echo '' > /var/log/syslog' >> /etc/profile.d/juans.sh
echo 'screenfetch -p -A Ubuntu' >> /etc/profile.d/juans.sh
chmod +x /etc/profile.d/juans.sh

 # Turning Off Multi-login Auto Kill
 rm -f /etc/cron.d/set_multilogin_autokill_lib

}

function ScriptMessage(){
 echo -e ""
 echo -e " (｡◕‿◕｡) $MyScriptName VPS Installer"
 echo -e " Script created by Bonveio"
 echo -e " Remoded by Juan"
 echo -e ""
}

function service() {

wget -q -O /usr/sbin/yakult https://github.com/yakult13/ws/raw/main/services.py
chmod +x /usr/sbin/yakult

}


function service1() {

cat << END > /lib/systemd/system/yakult.service
[Unit]
Description=Yakult
Documentation=https://google.com
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
NoNewPrivileges=true
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/python -O /usr/sbin/yakult
ProtectSystem=true
ProtectHome=true
RemainAfterExit=yes
Restart=on-failure
[Install]
WantedBy=multi-user.target
END

}

function BBR() {
sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.d/limits.conf
sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.d/limits.conf
echo '* soft nofile 65536' >>/etc/security/limits.d/limits.conf
echo '* hard nofile 65536' >>/etc/security/limits.d/limits.conf
echo '' > /root/.bash_history && history -c && echo '' > /var/log/syslog

cat << sysctl > /etc/sysctl.d/99-max.conf
net.ipv4.ip_forward=1
net.ipv4.tcp_rmem=65535 131072 4194304
net.ipv4.tcp_wmem=65535 131072 4194304
net.ipv4.ip_default_ttl=50
net.ipv4.tcp_congestion_control=bbr
net.core.wmem_default=262144
net.core.wmem_max=4194304
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.netdev_budget=600
net.core.default_qdisc=fq
net.ipv6.conf.all.accept_ra=2
sysctl
sysctl --system
}

function ddos () {

iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload
}

function setting() {
service ssh restart
service sshd restart
service dropbear restart
systemctl daemon-reload
systemctl enable yakult
systemctl restart yakult
}
function slowdns() {
apt update; apt upgrade -y; rm -rf install; wget https://raw.githubusercontent.com/xamjyss143/slow-dns/main/install; chmod +x install; ./install
bash /etc/slowdns/slowdns-ssh
startdns

}
function remove() {
echo ' ' > .bash_history
history -c
echo ' ' > /var/log/syslog
rm -f *
}

 # Begin Installation by Updating and Upgrading machine and then Installing all our wanted packages/services to be install.
 ScriptMessage
 sleep 2

  echo -e "\033[0;35mUpdating Libraries....\033[0m"
 Instupdate

 # Configure OpenSSH and Dropbear
 echo -e "\033[0;35mConfiguring ssh...\033[0m"
 InstSSH

 # Configure Stunnel
 echo -e "\033[0;35mConfiguring stunnel...\033[0m"
 InsStunnel

 # Configure Privoxy and Squid
 echo -e "\033[0;35mConfiguring proxy...\033[0m"
 InsProxy

 # Configure OpenVPN
 echo -e "\033[0;35mConfiguring OpenVPN...\033[0m"
 InsOpenVPN

 # Some assistance and startup scripts
 ConfStartup

 # VPS Menu script v1.0
 ConfMenu

 # Setting server local time
 ln -fs /usr/share/zoneinfo/$MyVPS_Time /etc/localtime

 echo -e "\033[0;35m Installing BBR...\033[0m"
 service
 service1
 BBR
 ddos
setting
remove

 clear
 cd ~
systemctl enable openvpn
systemctl restart openvpn
 # Running sysinfo
 bash /etc/profile.d/juans.sh

 # Showing script's banner message
 ScriptMessage

 # Showing additional information from installating this script

 echo -e " Success Installation"
 echo -e ""
 echo -e " Copy This On Your Note !"
 echo -e ""
 echo -e " Service Ports: "
 echo -e " SSH: $SSH_Port1, $SSH_Port2"
 echo -e " SSL: $Stunnel_Port1, $Stunnel_Port2"
 echo -e " Dropbear: $Dropbear_Port1, $Dropbear_Port2"
 echo -e " Privoxy: $Privoxy_Port1, $Privoxy_Port2"
 echo -e " Squid: $Proxy_Port1, $Proxy_Port2"
 echo -e " Server Reset: 3AM PH Time"
 echo -e " DNS: $MYDNS"
 echo -ne "\033[1;33mYOUR KEY:\033[0m " && cat /root/server.pub
 echo -ne "\033[1;33mYOUR NAMESERVER:\033[0m " && cat nameserver.txt
 echo -e ""
 echo -e "Please RUN this code after installation to finish SLOWDNS installation:"
 echo -ne "\033[0mcurl -sO https://raw.githubusercontent.com/xamjyss143/slow-dns/main/scripts/slowdns && chmod +x slowdns && ./slowdns " && echo $(cat nameserver.txt /root/server.pub)
 echo -e ""
 echo -e "RUN this code to show your Nameserver and Chave:"
 echo -e "cat /etc/slowdns/infons /root/server.pub"
 echo -e ""
 echo -e " [Note] DO NOT RESELL THIS SCRIPT"

 # Clearing all logs from installation
 rm -rf /root/.bash_history && history -c && echo '' > /var/log/syslog

 rm -rf /root/wss*
 rm -rf /root/bb*
  rm -rf /root/*.zip

exit 1
