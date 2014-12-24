From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH 2/3] net/fsl: remove irq assignment from xgmac_mdio
Date: Wed, 24 Dec 2014 02:22:45 +0000
Message-ID: <DM2PR0301MB08643B456EB87328ACF71CC5E2540@DM2PR0301MB0864.namprd03.prod.outlook.com>
References: <1419328019-27254-1-git-send-email-shh.xie@gmail.com>
 <54997817.6010108@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shh.xie@gmail.com" <shh.xie@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0106.outbound.protection.outlook.com ([207.46.100.106]:62772
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750806AbaLXCWs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 21:22:48 -0500
In-Reply-To: <54997817.6010108@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Tuesday, December 23, 2014 10:12 PM
> To: shh.xie@gmail.com; netdev@vger.kernel.org; davem@davemloft.net
> Cc: Xie Shaohui-B21989
> Subject: Re: [PATCH 2/3] net/fsl: remove irq assignment from xgmac_mdio
> 
> Hello.
> 
> On 12/23/2014 12:46 PM, shh.xie@gmail.com wrote:
> 
> > From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> > Which is wrong and not used, so no extra space needed by
> > mdio_alloc_size(), change the parameter accordingly.
> 
> > Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> > ---
> >   drivers/net/ethernet/freescale/xgmac_mdio.c | 3 +--
> >   1 file changed, 1 insertion(+), 2 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c
> > b/drivers/net/ethernet/freescale/xgmac_mdio.c
> > index 90adba1..72e0b85 100644
> > --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> > +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> > @@ -187,14 +187,13 @@ static int xgmac_mdio_probe(struct
> platform_device *pdev)
> >   		return ret;
> >   	}
> >
> > -	bus = mdiobus_alloc_size(PHY_MAX_ADDR * sizeof(int));
> > +	bus = mdiobus_alloc_size(0);
> 
>     It's now equivalent to a mere mdiobus_alloc().
[S.H] Yes, mdiobus_alloc() defined as:

static inline struct mii_bus *mdiobus_alloc(void)
{       
        return mdiobus_alloc_size(0);
} 

Should I use mdiobus_alloc() instead?

Thanks!
Shaohui
