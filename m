From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH v4 07/10] ARM: mx28: add the second fec device
 registration
Date: Tue, 11 Jan 2011 12:44:53 +0100
Message-ID: <20110111114453.GJ26617@pengutronix.de>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-8-git-send-email-shawn.guo@freescale.com>
 <20110111102909.GH26617@pengutronix.de>
 <20110111113951.GB2888@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerg@snapgear.com, B32542@freescale.com, netdev@vger.kernel.org,
	u.kleine-koenig@pengutronix.de, jamie@shareable.org,
	baruch@tkos.co.il, w.sang@pengutronix.de, r64343@freescale.com,
	eric@eukrea.com, bryan.wu@canonical.com, jamie@jamieiles.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	lw@karo-electronics.de
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39408 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534Ab1AKLoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 06:44:55 -0500
Content-Disposition: inline
In-Reply-To: <20110111113951.GB2888@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 11, 2011 at 07:39:52PM +0800, Shawn Guo wrote:
> Hi Sascha,
> 
> On Tue, Jan 11, 2011 at 11:29:09AM +0100, Sascha Hauer wrote:
> > On Thu, Jan 06, 2011 at 03:13:15PM +0800, Shawn Guo wrote:
> > > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > > ---
> > >  arch/arm/mach-mxs/mach-mx28evk.c |   28 +++++++++++++++++++++++++---
> > >  1 files changed, 25 insertions(+), 3 deletions(-)
> > > 
> > >  
> > >  static void __init mx28evk_init(void)
> > > @@ -117,7 +136,10 @@ static void __init mx28evk_init(void)
> > >  	mx28_add_duart();
> > >  
> > >  	mx28evk_fec_reset();
> > > -	mx28_add_fec(0, &mx28_fec_pdata);
> > > +	mx28_add_fec(0, &mx28_fec_pdata[0]);
> > > +#ifdef CONFIG_FEC2
> > > +	mx28_add_fec(1, &mx28_fec_pdata[1]);
> > > +#endif
> > 
> > Please don't do this. If you really want to make this configurable with
> > kconfig use a board specific option, not a driver specific option. I
> > think this should be made unconditional though.
> > 
> I will resend this patch as v5 than the whole patch set, if you
> do not mind.

ok

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
