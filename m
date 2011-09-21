From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 1/3] net/fec: change phy-reset-gpio request warning to
 debug message
Date: Wed, 21 Sep 2011 21:18:39 +0800
Message-ID: <20110921131838.GJ28907@S2100-06.ap.freescale.net>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-2-git-send-email-shawn.guo@linaro.org>
 <20110921112555.GE1966@pengutronix.de>
 <20110921120341.GG28907@S2100-06.ap.freescale.net>
 <20110921121159.GG1966@pengutronix.de>
 <20110921124423.GI28907@S2100-06.ap.freescale.net>
 <20110921125905.GI1966@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <patches@linaro.org>, <netdev@vger.kernel.org>,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:5337
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753510Ab1IUNJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2011 09:09:05 -0400
Content-Disposition: inline
In-Reply-To: <20110921125905.GI1966@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 02:59:05PM +0200, Wolfram Sang wrote:
> > > I agree that keeping it int is way better. But why not add it now to
> > > keep things proper and tested? If this patch gets accepted as it is and
> > > later someone else will add error checking to the caller, your platform
> > > will lose FEC support as a regression.
> > > 
> > Again, fec_reset_phy() failure is not a show-stopper.  We might not
> > want to make the probe fail because of that.
> 
> That would be an argument to make the function returning void?
> 
Hmm, it seems to be.  Ok, will send v3 to return void.

Regards,
Shawn

> Well, I still think something like 
> 
> 	/* No phy reset configured */
> 	if (phy_reset == -ENODEV)
> 		return 0;
> 
> might be cleaner, yet I don't have the setup to test such an approach.
> 
> So, I'll be quiet now and hope for no problems.
> 
> -- 
> Pengutronix e.K.                           | Wolfram Sang                |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |
