From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Fri, 13 Mar 2009 20:49:41 +0100
Message-ID: <20090313194941.GL5367@pengutronix.de>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com> <20090310211841.388619ca@nehalam> <F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net> <20090312.070554.96115441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: mboards@prograde.net, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:43147 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbZCMTus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 15:50:48 -0400
Content-Disposition: inline
In-Reply-To: <20090312.070554.96115441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 07:05:54AM -0700, David Miller wrote:
> From: Michael Cashwell <mboards@prograde.net>
> Date: Thu, 12 Mar 2009 09:41:38 -0400
> 
> > I'm confused by this. If I'm NFS-booting the board then how do I get
> > to those userland tools if I don't have a valid MAC address in place
> > to do the root mount?
> 
> Initial ramdisk.

That's maybe the right solution for big machines, but for small embedded
systems it's absolutely overkill. We have used Linux on several ten ARM
and PowerPC boards, and the only reason we ever needed an initrd was
on an IXP425 who needed a strange firmware which had a license.

Embedded boxes are often short on RAM, so wasting megabytes of space on
a box that maybe has 8...16 MB RAM just because of a mac address doesn't
sound like a good solution.

rsc
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
