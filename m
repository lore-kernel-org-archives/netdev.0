From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Tulip 21040 hangs with ifconfig promisc
Date: Sun, 14 Mar 2004 17:54:38 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3wu5nnzch.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This is:
Linux version ~2.6.4 (Red Hat Linux 3.3.2-1)) SMP kernel, UNI CPU.
(as of Mar 12 in bkcvs/linux-2.5/).

Acorp VIA77 mobo - AMD-K6 3D 500 MHz + VIA MVP3 chipset.
SMC EtherPower^2 (dual DECchip 21040 + 21050 PCI-PCI bridge)
All running out of ramdisk.

Doing "ifconfig eth0 promisc" kills the ethernet. Interrupts are gone,
nothing in dmesg. -promisc nor ifconfig down/up doesn't fix it,
only driver rmmod/insmod does.

de2104x PCI Ethernet driver v0.6 (Sep 1, 2003)
eth0: 21040 at 0xca81e000, 00:00:c0:d8:66:e0, IRQ 11
eth1: 21040 at 0xca820000, 00:00:c0:16:1b:c0, IRQ 12
eth0: enabling interface
eth0: set link 10baseT-HD
eth0:    mode 0xfffc0040, sia 0xffffffc4,0xffff8f01,0xffffffff,0xffff0000
eth0:    set mode 0xfffc0000, set sia 0x8f01,0xffff,0x0
eth0: link up, media 10baseT-HD
device eth0 entered promiscuous mode

Any idea?
-- 
Krzysztof Halasa, B*FH
