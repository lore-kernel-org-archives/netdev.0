From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 2991] New: vlan (8021q) is working bad with
 some sites and some ports
Date: Thu, 1 Jul 2004 00:28:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701002814.7f3bc516.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Thu, 1 Jul 2004 00:19:15 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 2991] New: vlan (8021q) is working bad with some sites and some ports


http://bugme.osdl.org/show_bug.cgi?id=2991

           Summary: vlan (8021q) is working bad with some sites and some
                    ports
    Kernel Version: 2.6.7
            Status: NEW
          Severity: high
             Owner: niv@us.ibm.com
         Submitter: roxwal@libero.it


Distribution: Vlan (8021q) lost ipv4 packet 
Hardware Environment: HP tc3100 + switch 3com 3c16886A 
Software Environment: Mandrake 10 official + kernel 2.6.7-2mdk 
Problem Description:  
While using vlan (eth0.2) for connection to internet mostly sites don't work 
(ex: www.ziobudda.net bad, punto-informatico.it ok) 
The connection starts but no packet are recived.  
tcpdump -i eth0.2 -vv -X host www.ziobudda.net 
tcpdump: listening on eth0.2, link-type EN10MB (Ethernet), capture size 96 
bytes 
09:03:48.715078 IP (tos 0x0, ttl  64, id 51924, offset 0, flags [DF], length: 
52) 81.112.63.189.32933 > 193.254.241.4.http: F [tcp sum ok] 
2920000677:2920000677(0) ack 2170843880 win 5840 <nop,nop,timestamp 1895751 
271281932> 
0x0000   4500 0034 cad4 4000 4006 2bbf 5170 3fbd        E..4..@.@.+.Qp?. 
0x0010   c1fe f104 80a5 0050 ae0b aca5 8164 72e8        .......P.....dr. 
0x0020   8011 16d0 df2c 0000 0101 080a 001c ed47        .....,.........G 
0x0030   102b 6f0c                                      .+o. 
09:03:48.723397 IP (tos 0x0, ttl  54, id 7661, offset 0, flags [DF], length: 
52) 193.254.241.4.http > 81.112.63.189.32933: . [tcp sum ok] 2897:2897(0) ack 
1 win 6432 <nop,nop,timestamp 271285501 1895751> 
0x0000   4500 0034 1ded 4000 3606 e2a6 c1fe f104        E..4..@.6....... 
0x0010   5170 3fbd 0050 80a5 8164 7e38 ae0b aca6        Qp?..P...d~8.... 
0x0020   8010 1920 c39b 0000 0101 080a 102b 7cfd        .............+|. 
0x0030   001c ed47                                      ...G 
09:03:48.826211 IP (tos 0x0, ttl  64, id 20222, offset 0, flags [DF], length: 
60) 81.112.63.189.32934 > 193.254.241.4.http: S [tcp sum ok] 
2985141064:2985141064(0) win 5840 <mss 1460,sackOK,timestamp 1895862 
0,nop,wscale 0> 
0x0000   4500 003c 4efe 4000 4006 a78d 5170 3fbd        E..<N.@.@...Qp?. 
0x0010   c1fe f104 80a6 0050 b1ed a348 0000 0000        .......P...H.... 
0x0020   a002 16d0 2907 0000 0204 05b4 0402 080a        ....)........... 
0x0030   001c edb6 0000 0000 0103 0300                  ............ 
09:03:48.834155 IP (tos 0x0, ttl  54, id 0, offset 0, flags [DF], length: 60) 
193.254.241.4.http > 81.112.63.189.32934: S [tcp sum ok] 2195619523:2195619523
(0) ack 2985141065 win 5792 <mss 1460,sackOK,timestamp 271285512 
1895862,nop,wscale 0> 
0x0000   4500 003c 0000 4000 3606 008c c1fe f104        E..<..@.6....... 
0x0010   5170 3fbd 0050 80a6 82de 7ec3 b1ed a349        Qp?..P....~....I 
0x0020   a012 16a0 9a50 0000 0204 05b4 0402 080a        .....P.......... 
0x0030   102b 7d08 001c edb6 0103 0300                  .+}......... 
09:03:48.834228 IP (tos 0x0, ttl  64, id 20223, offset 0, flags [DF], length: 
52) 81.112.63.189.32934 > 193.254.241.4.http: . [tcp sum ok] 1:1(0) ack 1 win 
5840 <nop,nop,timestamp 1895870 271285512> 
0x0000   4500 0034 4eff 4000 4006 a794 5170 3fbd        E..4N.@.@...Qp?. 
0x0010   c1fe f104 80a6 0050 b1ed a349 82de 7ec4        .......P...I..~. 
0x0020   8010 16d0 c8dd 0000 0101 080a 001c edbe        ................ 
0x0030   102b 7d08                                      .+}. 
09:03:48.836162 IP (tos 0x0, ttl  64, id 20224, offset 0, flags [DF], length: 
451) 81.112.63.189.32934 > 193.254.241.4.http: P 1:400(399) ack 1 win 5840 
<nop,nop,timestamp 1895872 271285512> 
0x0000   4500 01c3 4f00 4000 4006 a604 5170 3fbd        E...O.@.@...Qp?. 
0x0010   c1fe f104 80a6 0050 b1ed a349 82de 7ec4        .......P...I..~. 
0x0020   8018 16d0 78ce 0000 0101 080a 001c edc0        ....x........... 
0x0030   102b 7d08 4745 5420 2f20 4854 5450 2f31        .+}.GET./.HTTP/1 
0x0040   2e31 0d0a 436f 6e6e 6563 7469 6f6e 3a20        .1..Connection:. 
0x0050   4b65                                           Ke 
09:03:48.846287 IP (tos 0x0, ttl  54, id 973, offset 0, flags [DF], length: 
52) 193.254.241.4.http > 81.112.63.189.32934: . [tcp sum ok] 1:1(0) ack 400 
win 6432 <nop,nop,timestamp 271285513 1895872> 
0x0000   4500 0034 03cd 4000 3606 fcc6 c1fe f104        E..4..@.6....... 
0x0010   5170 3fbd 0050 80a6 82de 7ec4 b1ed a4d8        Qp?..P....~..... 
0x0020   8010 1920 c4fb 0000 0101 080a 102b 7d09        .............+}. 
0x0030   001c edc0 
 
(no more) 
 
the ping works and the telnet towards others ports (but 80) work 
if I use une other net card for direct connettion (eth1) internet connections 
works perfectly 
 
Steps to reproduce: 
hdsl + router cisco + 3com switch layer 3 + vlan 
eth0 local lan  
eth0.2 internet  
links www.ziobudda.net 
 
tks W:-}

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
