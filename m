From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH] net/fec: gasket needs to be enabled for some i.mx
Date: Fri, 8 Jul 2011 08:06:39 +0800
Message-ID: <20110708000638.GC12722@S2100-06.ap.freescale.net>
References: <20110630161935.GA7977@S2100-06.ap.freescale.net>
 <1309515082-7386-1-git-send-email-shawn.guo@linaro.org>
 <20110707.041257.670268148869400054.davem@davemloft.net>
 <20110707134157.GA12722@S2100-06.ap.freescale.net>
 <20110707184409.GH2824@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<s.hauer@pengutronix.de>, <troy.kisky@boundarydevices.com>,
	<u.kleine-koenig@pengutronix.de>, <shawn.guo@linaro.org>,
	<linux-arm-kernel@lists.infradead.org>, <LW@KARO-electronics.de>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:44078 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751807Ab1GHAAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 20:00:13 -0400
Content-Disposition: inline
In-Reply-To: <20110707184409.GH2824@ponder.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2011 at 12:44:09PM -0600, Grant Likely wrote:
> On Thu, Jul 07, 2011 at 09:41:58PM +0800, Shawn Guo wrote:
> > On Thu, Jul 07, 2011 at 04:12:57AM -0700, David Miller wrote:
> > > From: Shawn Guo <shawn.guo@linaro.org>
> > > Date: Fri,  1 Jul 2011 18:11:22 +0800
> > > 
> > > > On the recent i.mx (mx25/50/53), there is a gasket inside fec
> > > > controller which needs to be enabled no matter phy works in MII
> > > > or RMII mode.
> > > > 
> > > > The current code enables the gasket only when phy interface is RMII.
> > > > It's broken when the driver works with a MII phy.  The patch uses
> > > > platform_device_id to distinguish the SoCs that have the gasket and
> > > > enables it on these SoCs for both MII and RMII mode.
> > > > 
> > > > Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> > > > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > > 
> > > Acked-by: David S. Miller <davem@davemloft.net>
> > > --
> > 
> > Thanks, David.  I will try to get it through Sascha's tree after
> > the rebase again dt series.
> > 
> > Hi Sascha,
> > 
> > How should we proceed?  It seems Grant will take the fec-dt series
> > on his tree.  Would you then merge that tree into yours, so that I
> > can rebase this patch on your tree and get it go through there?
> 
> I should probably just take the lot.
> 
Thanks, Grant.  That makes people's life easier.  Please let me know
once you apply the dt series, so that I can start rebase the patch on
your tree.

-- 
Regards,
Shawn

