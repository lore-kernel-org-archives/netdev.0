From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Fri, 13 Mar 2009 13:12:20 -0700 (PDT)
Message-ID: <20090313.131220.66282017.davem@davemloft.net>
References: <F884D8C3-E35B-4239-8D72-165EE528FCAC@prograde.net>
	<20090312.070554.96115441.davem@davemloft.net>
	<20090313194941.GL5367@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mboards@prograde.net, shemminger@vyatta.com, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de
To: r.schwebel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32771
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759290AbZCMUMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:12:34 -0400
In-Reply-To: <20090313194941.GL5367@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Schwebel <r.schwebel@pengutronix.de>
Date: Fri, 13 Mar 2009 20:49:41 +0100

> On Thu, Mar 12, 2009 at 07:05:54AM -0700, David Miller wrote:
> > From: Michael Cashwell <mboards@prograde.net>
> > Date: Thu, 12 Mar 2009 09:41:38 -0400
> > 
> > > I'm confused by this. If I'm NFS-booting the board then how do I get
> > > to those userland tools if I don't have a valid MAC address in place
> > > to do the root mount?
> > 
> > Initial ramdisk.
> 
> That's maybe the right solution for big machines, but for small embedded
> systems it's absolutely overkill. We have used Linux on several ten ARM
> and PowerPC boards, and the only reason we ever needed an initrd was
> on an IXP425 who needed a strange firmware which had a license.
> 
> Embedded boxes are often short on RAM, so wasting megabytes of space on
> a box that maybe has 8...16 MB RAM just because of a mac address doesn't
> sound like a good solution.

Slipping every odd feature into the kernel on the basis that it might
be useful to some small group of people doesn't sound like good system
design to me.

And I know for a fact that with all of the effort people have been
investing into this stupid thread, they could have implemented the
necessary initrd they needed 10 times over.

I can't believe they have so much time, there must not be one of
those dreaded "deadline"'s approaching.
