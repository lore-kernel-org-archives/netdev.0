From: mmadore <mmadore@blarg.net>
Subject: 2.4.28 neighbour/arp problem
Date: Mon, 13 Dec 2004 10:57:20 -0800
Message-ID: <9b6c67c48842b0cd62ac6aeda45088d5@www.blargmail.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="b1_9b6c67c48842b0cd62ac6aeda45088d5"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--b1_9b6c67c48842b0cd62ac6aeda45088d5
Content-Type: text/plain; charset = "iso-8859-1"
Content-Transfer-Encoding: 8bit

Hi,

I am seeing some strange behavior with the changes to the neighbour/arp code that went into the 2.4.28 kernel.  When I first boot the system with 2.4.28, I cannot connect to other machines on my network.  If I print out the arp table, I will see something like this:

[root@node1 root]# arp
Address                  HWtype  HWaddress           Flags Mask            Ifaceiserver.mynet.com                (incomplete)                              eth0
dns.mynet.com            ether   00:90:27:34:5F:6A   C                     eth0
iserver.mynet.com        ether   00:E0:81:04:DC:F0   C                     eth0

For some reason, the system I am trying to connect to shows up twice.  If I bring down eth0 and then start it again, I can then connect to the system.  Also, If I wait for a number of minutes, the (incomplete) entry will disappear from the arp table and I can connect to the system.

If I apply the attached path to backout the arp/neighbour changes, then everthing seems to work fine.

The problem only occurs with 2.4.28.  Both 2.4.27 and 2.6.9 work correctly.  Also, I have reproduced this issue on RedHat 7.3, 8.0, 9 and Fedora Core 1 (using 2.4.28) with both Intel e1000 and Marvell gigabit (sk98lin).

Let me know if I can provide additional information.

Mike


--b1_9b6c67c48842b0cd62ac6aeda45088d5
Content-Type: text/html; charset = "iso-8859-1"
Content-Transfer-Encoding: 8bit

Hi,<br><br>I am seeing some strange behavior with the changes to the neighbour/arp code that went into the 2.4.28 kernel.&nbsp;&nbsp;When I first boot the system with 2.4.28, I cannot connect to other machines on my network.&nbsp;&nbsp;If I print out the arp table, I will see something like this:<br><br>[root@node1 root]# arp<br>Address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;HWtype&nbsp;&nbsp;HWaddress&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Flags
Mask&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ifaceiserver.mynet.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(incomplete)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;eth0<br>dns.mynet.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ether&nbsp;&nbsp; 00:90:27:34:5F:6A&nbsp;&nbsp; C&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; eth0<br>iserver.mynet.com&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ether&nbsp;&nbsp; 00:E0:81:04:DC:F0&nbsp;&nbsp; C&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; eth0<br>
 <br>For some reason, the system I am trying to connect to shows up twice.&nbsp;&nbsp;If I 
 bring
down eth0 and then start it again, I can then connect to the system.&nbsp;&nbsp;Also, If I wait for a number of minutes, the (incomplete) entry will disappear from the arp table and I can connect to the system.<br><br>If I apply the attached path to backout the arp/neighbour changes, then everthing seems to work fine.<br><br>The problem only occurs with 2.4.28.&nbsp;&nbsp;Both 2.4.27 and 2.6.9 work correctly.&nbsp;&nbsp;Also, I have reproduced this issue on RedHat 7.3, 8.0, 9 and Fedora Core 1 (using 2.4.28) with both Intel e1000 and Marvell gigabit (sk98lin).<br><br>Let me know if I can provide additional information.<br><br>Mike<br>



--b1_9b6c67c48842b0cd62ac6aeda45088d5--
