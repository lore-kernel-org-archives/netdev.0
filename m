From: amir_sarbazi <amir.sarbazi@gmail.com>
Subject: iptables-problem
Date: Sat, 26 Mar 2005 22:00:02 +0430
Message-ID: <43c5e5aa0503260930732eb697@mail.gmail.com>
Reply-To: backslash46@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 Hi all
  
 I have a Lan with range IP:192.168.1.0/24  that
 192.168.1.3 is my webserver.
 & have a firewall with 2 eth (eth0:192.168.1.2)
 & (eth1:217.218.68.20) .
 I want  when firewall get web request packet
 with eth1 then give it to eth0 & eth0 send
 packet to 192.168.1.3:80.
  
 I used these iptables that SNAT didn't work(Bad
 argument):
 iptables -A PREROUTING -t nat -p tcp -d
 217.218.68.20 --dport 80 -j SNAT --to
 192.168.1.2:80
 or(--to-source 192.168.1.3:80)
  
 But DNAT is working good:
 iptables -A PREROUTING -t nat -p tcp -d
 217.218.68.20 --dport 80 -j DNAT --to
 192.168.1.3 
  
 with regards.
  
 amir sarbazi
