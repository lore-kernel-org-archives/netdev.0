From: Meelis Roos <mroos@linux.ee>
Subject: 8139 resetting problem
Date: Mon, 19 Jan 2004 13:00:32 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0401191248200.8408-100000@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I helped to debug a problem with a onboard realtek (8100B/8139D) NIC in
a laptop (Clevo/KAPOK sceleton, sold as Ordi D27 in Estonia). The
problem is that sometimes Linux does not initialize the NIC well enough
so that I get messages about Tx timed out and DHCP not getting
addresses. DHCP server sees requests but the laptop never sees the
answers.

Trial and error showed that the problem occurs only when doing hibernate
from Windows XP Pro and then (instead of bringing up Windows) booting
into Linux. Even soft reboot (or halt from Linux) doesn't cure it. Going
back into Windows and doing shutdown or restart cures it.

This happened with different versions of Linux, 2.4.18 Debian, 2.6.0
Debian, custom 2.6.0 and Knoppix (whatever version the newest Knoppix
uses).

8139too and rtl8139 drivers in 2.4.18 behaved the same.

Is there anything that the 8139too driver could do to fully reset the
card on startup?

Jan 19 12:44:22 laptop kernel: 8139too Fast Ethernet driver 0.9.26
Jan 19 12:44:22 laptop kernel: PCI: Enabling device 0000:00:0a.0 (0000 -> 0003)
Jan 19 12:44:22 laptop kernel: eth0: RealTek RTL8139 at 0xce858000, 00:90:f5:21:db:d7, IRQ 11
Jan 19 12:44:22 laptop kernel: eth0:  Identified 8139 chip type 'RTL-8100B/8139D'
Jan 19 12:44:22 laptop kernel: Disabled Privacy Extensions on device c02e28e0(lo)
Jan 19 12:44:22 laptop kernel: eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
Jan 19 12:44:22 laptop kernel: NET: Registered protocol family 17
Jan 19 12:44:22 laptop kernel: eth0: no IPv6 routers present
Jan 19 12:44:22 laptop kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jan 19 12:44:22 laptop kernel: eth0: Tx queue start entry 4  dirty entry 0.
Jan 19 12:44:22 laptop kernel: eth0:  Tx descriptor 0 is 00002000. (queue head)
Jan 19 12:44:22 laptop kernel: eth0:  Tx descriptor 1 is 00002000.
Jan 19 12:44:22 laptop kernel: eth0:  Tx descriptor 2 is 00002000.
Jan 19 12:44:22 laptop kernel: eth0:  Tx descriptor 3 is 00002000.

-- 
Meelis Roos (mroos@linux.ee)
