From: john@BlueSkyTours.com
Subject: Realtek RTL8111B serious performance issues
Date: Tue, 17 Jul 2007 23:32:40 -0600 (MDT)
Message-ID: <Pine.SOC.4.64.0707172328150.3299@katana>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat1.blueskytours.com ([12.96.192.180]:11928 "HELO
	volcano.blueskytours.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1751776AbXGRFjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 01:39:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hi,

I originally sent this email to the linux-net list before realizing it
probably belonged on the netdev list.

I just subscribed to this list, so I apologize if this is a known issue.  I
did try looking through the archives, and did not see it there either.

We just put together a new "app server" based on a P35 chipset motherboard,
4 gigabytes of RAM, Q6600 processor, and integrated Realtek RTL8111B gigabit
NIC.  When we SSH or RSH into this machine, and try to run any X application
(emacs, firefox) the application's graphics are drawn *extremely* slowly.
It can take 10 seconds from the time an emacs window pops up until it is
done drawing all of it's icons.

Firefox is even worse.  Loading pages is painful.  The "spinning dots", in the
upper right and corner, never actually spin.  It takes a long time for a
page to be displayed, and when it is draw, it is all-at-once.  Scrolling a
page up/down is extremely jurky.

We are currently running kernel 2.6.22.1, but I have also tried going back
to 2.6.20.x without any change in behavior.

The NIC driver is loaded as:

kernel: eth0: RTL8168b/8111b at 0xffffc20000640000, 00:1a:4d:43:db:d4, IRQ 17

I tried going to Realtek's site to see if there was a newer driver, but the
only driver there seems to be for older kernels.

I finally put an old Linksys 10/100 PCI NIC in the system, and that has
SOLVED the problem.  We would prefer using the integrated NIC, however.


04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)
          Subsystem: Giga-byte Technology Unknown device e000
          Flags: bus master, fast devsel, latency 0, IRQ 17
          I/O ports at c000 [size=256]
          Memory at f8000000 (64-bit, non-prefetchable) [size=4K]
          [virtual] Expansion ROM at fb200000 [disabled] [size=64K]
          Capabilities: [40] Power Management version 2
          Capabilities: [48] Vital Product Data
          Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable-
          Capabilities: [60] Express Endpoint IRQ 0
          Capabilities: [84] Vendor Specific Information
          Capabilities: [100] Advanced Error Reporting
          Capabilities: [12c] Virtual Channel
          Capabilities: [148] Device Serial Number 68-81-ec-10-00-00-00-25
          Capabilities: [154] Power Budgeting

Anyone have any suggestions for solving this problem?

Thanks,

John


-- 

|         |
+--+  ==  |  John Patrick Poet                 Blue Sky Tours
|  |      |  Director of Systems Development   10832 Prospect Ave., N.E.
|     +---+  john@BlueSkyTours.COM             Albuquerque, N.M. 87112
|     |      Ph. 505 293 9462                  Fx. 505 293 6902
