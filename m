From: Anders Peter Fugmann <afu@fugmann.dhs.org>
Subject: Errors on eth0
Date: Mon, 15 Apr 2002 22:33:06 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CBB3902.1070509@fugmann.dhs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I hope this is the correct list to write to,
othervice please ignore this mail.

I have connected eth0 directly into my ADSL-modem (10BaseT), and I'm experiencing
errors on the interface.
Normal traffic works, but when sending a large number of small packets I see
the error counter incresing, and delays occur ( 1-2 sec), and packets are dropped.

Before I talk to my ISP, is there any way to see why this is happening.
I've tried to replace the network card and cable but nothing seems to help.

The kernel is 2.4.18. Ive tried to connect my personal machine running 2.5.7 instead,
and here i get collisions instead of errors. (lots of collisions.) The network card has
in all cases been set to 10Mbit-Half Duplex, based on autonegotiation.

Please reccommend a way to debug the problem.
Below is relevant output from /proc/pci, 'ifconfig' and from lsmod.

Thanks in advance
Anders Fugmann

P.s. Please cc me on all replies, as I'm currently not subscribed to the list.


/sbin/ifconfig:
eth0      Link encap:Ethernet  HWaddr 00:E0:29:64:63:97
           inet addr:62.242.xxx.xxx  Bcast:62.242.xxx.xxx  Mask:255.255.255.252
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:71960 errors:34 dropped:0 overruns:0 frame:0
                                   ^^
           TX packets:77957 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:100
           RX bytes:28309233 (26.9 MiB)  TX bytes:17848025 (17.0 MiB)
           Interrupt:12 Base address:0xa000

/proc/pci:
   Bus  0, device   9, function  0:
     Ethernet controller: Accton Technology Corporation SMC2-1211TX (rev 16).
       IRQ 12.
       Master Capable.  Latency=32.  Min Gnt=32.Max Lat=64.
       I/O at 0xd800 [0xd8ff].
       Non-prefetchable 32 bit memory at 0xdf000000 [0xdf0000ff].

lsmod:
8139too                12512   1  (autoclean)
mii                     1056   0  (autoclean) [8139too]

