From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: ip neigh output are incomplete, 3.4.1
Date: Thu, 07 Jun 2012 16:09:44 +0300
Message-ID: <ea0a16e085389e68b480c4b0baf05645@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42521 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758095Ab2FGNJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 09:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a host with large L2 network (around 100 L2TP tunnels bridged to 
one interface). 3.4.1 kernel, x86, 32bit.

ip route add 172.16.0.0/16 dev br0

GlobalNAT ~ # cat /proc/net/arp |wc -l
2
GlobalNAT ~ # cat /proc/net/arp |wc -l
3575
GlobalNAT ~ # cat /proc/net/arp |wc -l
4613
GlobalNAT ~ # cat /proc/net/arp |wc -l
5117

And at same time
GlobalNAT /config # ip neigh |wc -l
52
GlobalNAT /config # ip neigh
172.16.1.94 dev br0 lladdr ea:2b:dd:8c:a6:96 REACHABLE
172.16.188.36 dev br0  INCOMPLETE
172.16.21.67 dev br0 lladdr aa:75:b5:04:01:1a REACHABLE
172.16.199.127 dev br0 lladdr 2e:64:5c:61:92:be REACHABLE
172.16.219.100 dev br0 lladdr 82:2f:33:ec:31:a9 REACHABLE
172.16.212.171 dev br0 lladdr be:d0:90:8a:97:35 REACHABLE
172.16.134.232 dev br0  FAILED
172.16.47.155 dev br0 lladdr 52:2e:4b:d1:d7:73 REACHABLE
172.16.67.128 dev br0 lladdr 22:c8:b2:a6:d8:17 REACHABLE
172.16.107.74 dev br0 lladdr 5a:ed:4f:35:32:94 REACHABLE
172.16.176.131 dev br0 lladdr b6:cf:5c:6e:84:88 REACHABLE
172.16.196.104 dev br0 lladdr e6:ec:2a:77:8d:ab REACHABLE
172.16.167.249 dev br0 lladdr be:13:c5:b2:be:f6 REACHABLE
172.16.49.108 dev br0 lladdr ea:97:c7:a9:a5:40 REACHABLE
172.16.71.34 dev br0 lladdr 2e:27:29:da:fc:2e REACHABLE
172.16.42.179 dev br0  INCOMPLETE
172.16.33.41 dev br0 lladdr 2e:64:5c:61:92:be REACHABLE
172.16.4.186 dev br0 lladdr 16:f9:a1:00:9d:c9 REACHABLE
172.16.104.51 dev br0 lladdr c6:1c:7e:2f:fe:1e REACHABLE
172.16.242.165 dev br0 lladdr 5a:ed:4f:35:32:94 REACHABLE
172.16.124.24 dev br0  INCOMPLETE
172.16.57.176 dev br0 lladdr 4e:70:0f:5c:d0:f3 REACHABLE
172.16.206.125 dev br0 lladdr 82:41:c6:78:56:36 REACHABLE
172.16.128.186 dev br0  INCOMPLETE
172.16.10.45 dev br0 lladdr 5e:15:f2:8d:8a:ab REACHABLE
172.16.21.136 dev br0 lladdr aa:75:b5:04:01:1a REACHABLE
172.16.61.82 dev br0 lladdr be:13:c5:b2:be:f6 REACHABLE
172.16.248.24 dev br0 lladdr 1a:f7:d5:2f:98:36 REACHABLE
172.16.239.142 dev br0 lladdr c6:1c:7e:2f:fe:1e REACHABLE
172.16.14.207 dev br0 lladdr 5e:15:f2:8d:8a:ab REACHABLE
172.16.134.45 dev br0 lladdr 8e:5a:26:d7:e6:ba REACHABLE
172.16.252.186 dev br0 lladdr 62:79:87:21:b4:46 REACHABLE
172.16.154.18 dev br0 lladdr 2a:39:28:65:80:37 REACHABLE
172.16.194.220 dev br0 lladdr ba:18:38:24:86:07 REACHABLE
172.16.76.79 dev br0 lladdr 62:25:4b:70:9e:f2 REACHABLE
172.16.234.166 dev br0 lladdr 6e:67:51:cd:a6:d4 REACHABLE
172.16.67.197 dev br0 lladdr 22:c8:b2:a6:d8:17 REACHABLE
172.16.49.177 dev br0 lladdr ea:97:c7:a9:a5:40 REACHABLE
172.16.118.234 dev br0 lladdr e2:3a:a3:0d:02:4d REACHABLE
172.16.169.15 dev br0  INCOMPLETE
172.16.100.214 dev br0 lladdr 56:a4:8f:1f:46:58 REACHABLE
172.16.71.103 dev br0 lladdr 2e:27:29:da:fc:2e REACHABLE
172.16.91.76 dev br0 lladdr d6:a0:18:9f:a3:21 REACHABLE
172.16.229.190 dev br0 lladdr d6:38:bd:40:02:4f REACHABLE
172.16.93.29 dev br0 lladdr 82:35:37:e8:11:c2 REACHABLE
172.16.113.2 dev br0 lladdr c6:5e:c6:f5:44:5e REACHABLE
172.16.104.120 dev br0 lladdr c6:1c:7e:2f:fe:1e REACHABLE
172.16.95.238 dev br0  INCOMPLETE
172.16.106.73 dev br0 lladdr 5a:ed:4f:35:32:94 REACHABLE
172.16.146.19 dev br0 lladdr ea:2b:dd:8c:a6:96 REACHABLE
172.16.235.49 dev br0 lladdr be:d0:90:8a:97:35 REACHABLE
172.16.255.22 dev br0  INCOMPLETE

ip neigh show dev br0 showing the same, 52 hosts only
Trying to set larger rcvbuf won't help, for example
ip -rcvbuf 1000000 ip neigh

Short sample from /proc/net/arp
172.16.41.227    0x1         0x2         5a:ed:4f:35:32:94     *        
br0
172.16.61.200    0x1         0x2         be:13:c5:b2:be:f6     *        
br0
172.16.239.4     0x1         0x2         c6:1c:7e:2f:fe:1e     *        
br0
172.16.3.234     0x1         0x2         5a:ed:4f:35:32:94     *        
br0
172.16.161.65    0x1         0x2         96:cf:d5:8a:85:7f     *        
br0
172.16.14.69     0x1         0x2         5e:15:f2:8d:8a:ab     *        
br0
172.16.212.102   0x1         0x2         be:d0:90:8a:97:35     *        
br0
172.16.252.48    0x1         0x2         62:79:87:21:b4:46     *        
br0
172.16.125.25    0x1         0x2         d6:3f:35:6c:69:a5     *        
br0
172.16.56.224    0x1         0x2         d6:a0:18:9f:a3:21     *        
br0
172.16.76.197    0x1         0x2         62:25:4b:70:9e:f2     *        
br0
172.16.67.59     0x1         0x2         22:c8:b2:a6:d8:17     *        
br0
172.16.156.89    0x1         0x2         6e:bd:24:97:4f:fb     *        
br0
172.16.107.5     0x1         0x2         5a:ed:4f:35:32:94     *        
br0
172.16.245.119   0x1         0x2         5a:1d:72:ba:39:1c     *        
br0
172.16.176.62    0x1         0x2         b6:cf:5c:6e:84:88     *        
br0

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
