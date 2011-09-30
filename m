From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: conntrack events over netlink flood
Date: Fri, 30 Sep 2011 15:15:41 +0300
Message-ID: <069917f11e06f3cf2e1ce9715f435b61@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34006 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491Ab1I3MYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 08:24:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Hi

 After enabling events and running conntrack -E i notice flood in output 
 of server that have PPPoE and PPTP connections. Here is the output:

 OfficeNAT ~ # conntrack  -E
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
 [DESTROY] tcp      6 src=194.146.153.22 dst=194.146.153.20 sport=59986 
 dport=22 src=194.146.153.20 dst=194.146.153.22 sport=22 dport=59986 
 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]
  [UPDATE] gre      47 17999 src=192.168.0.140 dst=192.168.0.1 
 srckey=0x0 dstkey=0x3 src=192.168.0.1 dst=192.168.0.140 srckey=0x3 
 dstkey=0x0 [ASSURED]

 Inside VPN there is nothing abnormal:
 OfficeNAT ~ # tcpdump -ni eth1 host 192.168.0.140
 tcpdump: verbose output suppressed, use -v or -vv for full protocol 
 decode
 listening on eth1, link-type EN10MB (Ethernet), capture size 65535 
 bytes
 15:14:25.197228 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871343, ack 23926537, length 286: IP 10.190.197.4.8291 > 
 10.0.0.11.34297: Flags [P.], seq 2294356048:2294356262, ack 1493604004, 
 win 7176, options [nop,nop,TS val 156039405 ecr 70523361], length 214
 15:14:25.197720 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926538, ack 36871342, length 84: IP 10.0.0.11 > 80.83.21.25: ICMP echo 
 request, id 47921, seq 62122, length 44
 15:14:25.208438 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926539, ack 36871343, length 72: IP 10.0.0.11.34297 > 
 10.190.197.4.8291: Flags [.], ack 214, win 502, options [nop,nop,TS val 
 70523364 ecr 156039405], length 0
 15:14:25.208455 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926540, length 80: IP 10.0.0.11 > 80.83.21.27: ICMP echo request, id 
 64042, seq 29149, length 44
 15:14:25.208488 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926541, length 140: IP 10.0.0.11.59486 > 10.55.23.1.8291: Flags [P.], 
 seq 3129587623:3129587695, ack 1529616820, win 964, options [nop,nop,TS 
 val 70523364 ecr 1211500666], length 72
 15:14:25.218655 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871344, ack 23926541, length 112: IP 10.25.65.3 > 10.0.0.11: ICMP time 
 exceeded in-transit, length 72
 15:14:25.219092 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926542, length 68: IP 10.0.0.11.41472 > 10.190.199.4.8291: Flags [.], 
 ack 937942646, win 502, options [nop,nop,TS val 70523366 ecr 510725509], 
 length 0
 15:14:25.228513 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926543, ack 36871344, length 84: IP 10.0.0.11 > 194.146.152.54: ICMP 
 echo request, id 45864, seq 24534, length 44
 15:14:25.228524 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926544, length 80: IP 10.0.0.11 > 194.146.152.54: ICMP echo request, 
 id 24373, seq 15283, length 44
 15:14:25.228601 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926545, length 234: IP 10.0.0.11.49437 > 192.168.20.55.8291: Flags 
 [P.], seq 2487750543:2487750709, ack 830585230, win 819, options 
 [nop,nop,TS val 70523366 ecr 1211500747], length 166
 15:14:25.233437 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871345, ack 23926545, length 141: IP 192.168.20.55.8291 > 
 10.0.0.11.49437: Flags [P.], seq 1:70, ack 166, win 11700, options 
 [nop,nop,TS val 1211500757 ecr 70523366], length 69
 15:14:25.235266 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871346, length 173: IP 10.190.199.4.8291 > 10.0.0.11.41472: Flags 
 [P.], seq 1:106, ack 0, win 8424, options [nop,nop,TS val 510725517 ecr 
 70523366], length 105
 15:14:25.235778 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, ack 
 36871346, no-payload, length 12
 15:14:25.236650 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871347, length 1316: IP 10.55.23.1.8291 > 10.0.0.11.59486: Flags [.], 
 seq 1:1249, ack 72, win 6084, options [nop,nop,TS val 1211500758 ecr 
 70523364], length 1248
 15:14:25.236842 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871348, length 1316: IP 10.55.23.1.8291 > 10.0.0.11.59486: Flags [.], 
 seq 1249:2497, ack 72, win 6084, options [nop,nop,TS val 1211500758 ecr 
 70523364], length 1248
 15:14:25.236963 IP 192.168.0.1 > 192.168.0.140: GREv1, call 0, seq 
 36871349, length 1316: IP 10.55.23.1.8291 > 10.0.0.11.59486: Flags [.], 
 seq 2497:3745, ack 72, win 6084, options [nop,nop,TS val 1211500758 ecr 
 70523364], length 1248
 15:14:25.237455 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, seq 
 23926546, length 229: IP 10.0.0.11.41472 > 10.190.199.4.8291: Flags 
 [P.], seq 0:161, ack 1, win 502, options [nop,nop,TS val 70523367 ecr 
 510725509], length 161
 15:14:25.237786 IP 192.168.0.140 > 192.168.0.1: GREv1, call 3, ack 
 36871349, no-payload, length 12

 Is it considered as a bug? I think it should not send on each packet 
 conntrack event.

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
