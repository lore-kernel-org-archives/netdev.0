From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: (no subject)
Date: 21 Feb 2003 11:38:54 -0000
Sender: linux-mips-bounce@linux-mips.org
Message-ID: <20030221113854.18121.qmail@webmail17.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed
Cc: linux-mips@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org


Well, i have a Linux machine i686 and an IAD based on MIPS 32-bit 
arch,
both enabled with IPv6.

Linux with 2.4.18-14 based on i686 configured as...
# ip -6 addr add 3ff3:1234::1/64 dev eth0
# ip -6 route add 3ffe:1234/64 dev eth0

IAD with 2.4.5-pre1 kernel based on MIPS 32-bit core configured 
as...
# ip -6 addr add 3ff3:1234::2/64 dev epmac1
# ip -6 route add 3ff3:1234/64dev epmac1
--------------------------------------------------
My IAD has a Flash, where the Linux kernel and the filesystem
images are present.
Flash size = 16MB
Filesystem is jffs2
Generated partitions are...
yamon partition size:2048 Kb
kernel partition size: 1024 Kb
rw image size: 10624 Kb
env partition size:128 Kb

Total: 13824 Kb
------------------------------

These two are connected in a IPv4 based LAN.
When i try to ping6 from Linux machine to the IAD,
my IAD hangs and generates a kernel OOps message.
Below is the snap shot of the message...

Following message is produced at the IAD terminal.....

# Unable to handle kernel paging request at virtual address 
00000000, epc == 802
4ce74, ra == 802592a8
Oops in fault.c:do_page_fault, line 172:
$0 : 00000000 1000fc00 8024ce70 8032bbbc
$4 : 00000000 83cbf120 00000000 83cbf17c
$8 : 00000001 0000000f 8030e000 00000003
$12: 00000416 83f69e18 00000000 8030914b
$16: fffffffd 00000000 00000018 c0026d20
$20: 81120dc0 83cbf17c 83cbf17c 00000000
$24: 00000001 2ac1d440
$28: 80106000 80107d78 83cbf120 802592a8
epc   : 8024ce74
Status: 1000fc03
Cause : 00800008
Process swapper (pid: 0, stackpage=80106000)
Stack: 00000008 00000000 83a00000 00000000 fd010018 83a11860 
8031fd50 00000000
        00000000 8024ca40 00000000 0000002c 8e8e1dac 00000000 
fffffffd 83cbf120
        00000000 83cbf17c c0026d20 00000000 00000000 00000000 
800e1d38 80259b0c
        83a53346 801efd1c 83a53346 839e92a0 00000000 83a118e0 
83a53346 00000000
        8022a1ec 80229e90 00000001 83cbf120 0000000e 8008a0e0 
04000000 00000000
        801f9384 ...
Call Trace: [<8024ca40>] [<c0026d20>] [<80259b0c>] [<801efd1c>] 
[<8022a1ec>] [<8
0229e90>] [<801f9384>] [<8024c97c>] [<8011f6b0>] [<8011f214>] 
[<801f5674>] [<801
1af14>] [<8011f73c>] [<8011ad88>] [<8011aacc>] [<8011aacc>] 
[<801117cc>] [<80111
7cc>] [<8010a478>] [<8010dee8>] [<80107fe0>] [<80125700>] 
[<801117cc>] [<8010600
0>] [<80107f60>] [<8010870c>] [<801086f0>] [<80108a78>] 
[<80115470>] [<802bfffc>
] [<802b7d30>] [<802c0b48>] [<801005e8>]
Code: 03e00008  27bd0030  00803021 <8cc50000> 30a400e0  10800003  
240300e0  1483
0034  24020001

Suggestions/Tips are welcome.

-San
-------------------------------------
