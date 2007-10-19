From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] Marvell Orion SoC ethernet driver
Date: Fri, 19 Oct 2007 04:02:57 +0200
Message-ID: <20071019020257.GA16037@xi.wantstofly.org>
References: <20071016192806.GD19618@xi.wantstofly.org> <1192570275.14601.10.camel@sakura.staff.proxad.net> <20071018011536.GA3704@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tzachi@marvell.com, nico@cam.org
To: Maxime Bizon <mbizon@freebox.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:60945 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933797AbXJSCDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:03:01 -0400
Content-Disposition: inline
In-Reply-To: <20071018011536.GA3704@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 18, 2007 at 03:15:36AM +0200, Lennert Buytenhek wrote:

> > > +#define PORT_CONF		0x400
> > > +#define PORT_CONF_EXT		0x404
> > > +#define PORT_MAC_LO		0x414
> > > +#define PORT_MAC_HI		0x418
> > > +#define PORT_SDMA		0x41c
> > > +#define PORT_SERIAL		0x43c
> > > +#define PORT_STAT		0x444
> > > +#define PORT_TXQ_CMD		0x448
> > > +#define PORT_MTU		0x458
> > > +#define PORT_CAUSE		0x460
> > > +#define PORT_CAUSE_EXT		0x464
> > > +#define PORT_MASK		0x468
> > > +#define PORT_MASK_EXT		0x46c
> > > +#define PORT_TX_THRESH		0x474
> > 
> > This driver seems to support the same hardware as mv643xx_eth, any
> > chance you could use it to avoid code duplication ?
> 
> Interesting.  After some asking around, it appears that the mv643xx
> ethernet silicon block is indeed very similar to the ethernet silicon
> block found the in Orion ARM SoCs.
> 
> We'll work on getting Orion to use mv643xx_eth.  Thanks for pointing
> this out.

Okay, patchset coming up.
