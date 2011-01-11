From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v4 07/10] ARM: mx28: add the second fec device
 registration
Date: Tue, 11 Jan 2011 19:39:52 +0800
Message-ID: <20110111113951.GB2888@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
 <1294297998-26930-8-git-send-email-shawn.guo@freescale.com>
 <20110111102909.GH26617@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutronix.de>, <lw@karo-electronics.de>,
	<w.sang@pengutronix.de>, <jamie@jamieiles.com>,
	<jamie@shareable.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:48268
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752979Ab1AKLiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 06:38:10 -0500
Received: from mail25-va3 (localhost.localdomain [127.0.0.1])	by
 mail25-va3-R.bigfish.com (Postfix) with ESMTP id 2D45F11F061B	for
 <netdev@vger.kernel.org>; Tue, 11 Jan 2011 11:38:07 +0000 (UTC)
Received: from VA3EHSMHS006.bigfish.com (unknown [10.7.14.243])	by
 mail25-va3.bigfish.com (Postfix) with ESMTP id B5CD2EC80CD	for
 <netdev@vger.kernel.org>; Tue, 11 Jan 2011 11:37:19 +0000 (UTC)
Received: from az33smr01.freescale.net (az33smr01.freescale.net
 [10.64.34.199])	by az33egw02.freescale.net (8.14.3/8.14.3) with ESMTP id
 p0BBb7rg012380	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 04:37:07 -0700
 (MST)
Received: from ubuntu.localdomain (ubuntu-010192242196.ap.freescale.net
 [10.192.242.196])	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id
 p0BBb6p5027496	for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 05:37:06 -0600
 (CST)
Content-Disposition: inline
In-Reply-To: <20110111102909.GH26617@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sascha,

On Tue, Jan 11, 2011 at 11:29:09AM +0100, Sascha Hauer wrote:
> On Thu, Jan 06, 2011 at 03:13:15PM +0800, Shawn Guo wrote:
> > Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> > ---
> >  arch/arm/mach-mxs/mach-mx28evk.c |   28 +++++++++++++++++++++++++---
> >  1 files changed, 25 insertions(+), 3 deletions(-)
> > 
> >  
> >  static void __init mx28evk_init(void)
> > @@ -117,7 +136,10 @@ static void __init mx28evk_init(void)
> >  	mx28_add_duart();
> >  
> >  	mx28evk_fec_reset();
> > -	mx28_add_fec(0, &mx28_fec_pdata);
> > +	mx28_add_fec(0, &mx28_fec_pdata[0]);
> > +#ifdef CONFIG_FEC2
> > +	mx28_add_fec(1, &mx28_fec_pdata[1]);
> > +#endif
> 
> Please don't do this. If you really want to make this configurable with
> kconfig use a board specific option, not a driver specific option. I
> think this should be made unconditional though.
> 
I will resend this patch as v5 than the whole patch set, if you
do not mind.

-- 
Regards,
Shawn

