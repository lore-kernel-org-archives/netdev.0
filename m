From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [PATCH] net: phy: dp83848: Support ethernet pause frames
Date: Fri, 2 Dec 2016 15:52:40 +0100
Message-ID: <20161202145240.GZ19016@axis.com>
References: <20161202142203.GY19016@axis.com>
 <80ee8058-7d6b-ea88-7ec6-20daf50a1fce@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Nilsson <jespern@axis.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Roger Quadros <rogerq@ti.com>,
        "David S. Miller" <davem@davemloft.net>,
        Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Andrew F. Davis" <afd@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:55301 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933652AbcLBOwn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 09:52:43 -0500
Content-Disposition: inline
In-Reply-To: <80ee8058-7d6b-ea88-7ec6-20daf50a1fce@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2016 at 08:35:23AM -0600, Andrew F. Davis wrote:
> On 12/02/2016 08:22 AM, Jesper Nilsson wrote:
> > According to the documentation, the PHYs supported by this driver
> > can also support pause frames. Announce this to be so.
> > Tested with a TI83822I.
> > 
> 
> Looks like all PHYs supported by this driver do, so:
> 
> Acked-by: Andrew F. Davis <afd@ti.com>
> 
> > Signed-off-by: Jesper Nilsson <jesper.nilsson@axis.com>
> > ---
> >  drivers/net/phy/dp83848.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
> > index 800b39f..6e4117f 100644
> > --- a/drivers/net/phy/dp83848.c
> > +++ b/drivers/net/phy/dp83848.c
> > @@ -88,7 +88,8 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
> >  		.phy_id		= _id,				\
> >  		.phy_id_mask	= 0xfffffff0,			\
> >  		.name		= _name,			\
> > -		.features	= PHY_BASIC_FEATURES,		\
> > +		.features	= (PHY_BASIC_FEATURES |		\
> > +			SUPPORTED_Pause | SUPPORTED_Asym_Pause),\
> 
> Aligning these may look nicer though.

Agreed, will send a v2.

> >  		.flags		= PHY_HAS_INTERRUPT,		\
> >  								\
> >  		.soft_reset	= genphy_soft_reset,		\
> > 

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
