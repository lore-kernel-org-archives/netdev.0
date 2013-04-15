From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 0/5 v2] mv643xx_eth: device tree bindings
Date: Mon, 15 Apr 2013 09:43:25 -0400
Message-ID: <20130415134325.GB28693@titan.lakedaemon.net>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <20130411165303.GI28693@titan.lakedaemon.net>
 <20130413172126.6cca0809@skate>
 <20130413190037.GY28693@titan.lakedaemon.net>
 <1365995234.3566.17.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <florian@openwrt.org>, davem@davemloft.net,
	moinejf@free.fr, andrew@lunn.ch, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, rob.herring@calxeda.com,
	grant.likely@secretlab.ca, jogo@openwrt.org,
	buytenh@wantstofly.org, jm@lentin.co.uk,
	linux-arm-kernel@lists.infradead.org,
	sebastian.hesselbarth@gmail.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:62649 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab3DONoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 09:44:05 -0400
Content-Disposition: inline
In-Reply-To: <1365995234.3566.17.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 04:07:14AM +0100, Ben Hutchings wrote:
> On Sat, 2013-04-13 at 15:00 -0400, Jason Cooper wrote:
> > On Sat, Apr 13, 2013 at 05:21:26PM +0200, Thomas Petazzoni wrote:
> > > Dear Jason Cooper,
> > > 
> > > On Thu, 11 Apr 2013 12:53:03 -0400, Jason Cooper wrote:
> > > 
> > > > With this and Thomas' pci series, we will have Kirkwood fully
> > > > converted to devicetree, can begin removing board files, and finally
> > > > begin migrating everything over to mach-mvebu/.  This will lead to
> > > > the removal of five directories under arch/arm/ (plat-orion,
> > > > mach-kirkwood, mach-orion5x, mach-dove, and mach-mv78xx0).
> > > 
> > > No, we can't remove mach-orion5x and mach-mv78xx0 for now, they have
> > > not been converted at all in terms of gpio/pinmux support. I've started
> > > writing some pinmux code for orion5x but it's not ready.
> [...]
> > Also, I have a feeling that not all legacy boards will get converted
> > over.  If there is no interest or no way to test, certains boards may
> > get deprecated.
> 
> Debian supports many Kirkwood and Orion 5x systems.  A call for testing
> on the debian-arm@lists.debian.org list might be worthwhile.

definitely.

> I would be very glad to see kirkwood, orion5x and mv78xx0 merged - we
> build natively and this takes about 8 hours for each configuration.

That's the plan, build an armv5 kernel, and dtb's for all the boards.
Then, an armv7 kernel for the armadaXP/370 boards, etc.

thx,

Jason.
