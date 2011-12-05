From: Chris Adams <cmadams@hiwaay.net>
Subject: Re: r8169 performance?
Date: Sun, 4 Dec 2011 18:46:50 -0600
Message-ID: <20111205004650.GA5948@hiwaay.net>
References: <20111204211007.GA32098@hiwaay.net> <20111204234004.GA32515@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hayeswang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fly.hiwaay.net ([216.180.54.1]:55208 "EHLO fly.hiwaay.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755881Ab1LEAq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 19:46:59 -0500
Content-Disposition: inline
In-Reply-To: <20111204234004.GA32515@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once upon a time, Francois Romieu <romieu@fr.zoreil.com> said:
> Chris Adams <cmadams@hiwaay.net> :
> [...]
> > Are there any suggestions for what I might be able to do to improve
> > throughput?  Is there a driver issue, or is it in how the motherboard
> > implemented the NIC ?
> 
> Can you grep for the r8169 lines in the dmesg of both computers and
> send the XID lines ?
> 
> It should show if the nics are the same or not.

On the "problem" computer (on Fedora 16, kernel 3.1.2):

[    7.101106] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    7.102665] r8169 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    7.107308] r8169 0000:02:00.0: setting latency timer to 64
[    7.107370] r8169 0000:02:00.0: irq 42 for MSI/MSI-X
[    7.107703] r8169 0000:02:00.0: eth0: RTL8168d/8111d at 0xffffc900112fc000, 00:19:66:f2:dc:0b, XID 081000c0 IRQ 42

On the "okay" computer (on Fedora 14, kernel 2.6.35.14):

[    9.053574] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    9.053594] r8169 0000:06:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    9.053689] r8169 0000:06:00.0: setting latency timer to 64
[    9.053740] r8169 0000:06:00.0: irq 47 for MSI/MSI-X
[    9.053830] r8169 0000:06:00.0: eth0: RTL8168d/8111d at 0xffffc90012998000, 6c:f0:49:b7:67:91, XID 083000c0 IRQ 47

Both are configured with static IPv4/v6 addresses (no NetworkManager).
The only other config difference I can think of is that the "okay"
computer is using bridging (eth0 in br0, IP config on br0) so I can
bridge virtual machines to the LAN.

-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
