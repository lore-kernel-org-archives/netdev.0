From: <sbenni@gmx.de>
Subject: Re: r8169 not advertising 1000mbit after suspend anymore
Date: Wed, 22 Jul 2009 11:41:28 +0200
Message-ID: <20090722114128.2d8a7f27@pluto-lenny.milky.way>
References: <20090719190937.7393ea99@pluto-lenny.milky.way>
 <20090721223741.GA24735@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:46491 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750909AbZGVJif (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 05:38:35 -0400
In-Reply-To: <20090721223741.GA24735@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jul 2009 00:37:41 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Benjamin S. <sbenni@gmx.de> :
> [...]
> > I have a Gigabyte GA-MA78G-DS3H mainboard with a RTL8111/8168B Realtek 
> > Gigabit Ethernet Controller. Until first suspend everything works as 
> > expected, but after suspend only 100mbit are used instead of 1000.
> 
> Which kernel do you use ?

2.6.30

> > mii-tool after setting speed to 1000 with "ethtool -s eth0 speed 1000":
> > eth0: negotiated 1000baseT-FD flow-control, link ok
> [snip]
> 
> At which point it works correctly again, right ?

Yes. After resetting speed with ethtool file transfers with 25MB/s
between my router and my computer are possible again.

> 
> At least some 8168 appear to lose the link settings :o/
> 
> Please send the XID line of the offender taken from dmesg.

[    2.802073] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    2.802132] r8169 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    2.802186] r8169 0000:02:00.0: setting latency timer to 64
[    2.802255] r8169 0000:02:00.0: irq 26 for MSI/MSI-X
[    2.802334] PM: Adding info for No Bus:eth0
[    2.802620] eth0: RTL8168c/8111c at 0xffffc20000668000, 00:1f:d0:53:f6:89, XID 3c4000c0 IRQ 26



Benjamin
