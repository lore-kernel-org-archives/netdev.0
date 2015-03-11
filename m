From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [linuxppc-release] [PATCH] net/fsl: remove dependency FSL_SOC
 from MDIO
Date: Wed, 11 Mar 2015 02:39:39 +0000
Message-ID: <BLUPR03MB14757C141DF1D6EA26F7484DE2190@BLUPR03MB1475.namprd03.prod.outlook.com>
References: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
 <54FEEF00.3060201@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Scott Wood <scottwood@freescale.com>
To: Emilian Medve <Emilian.Medve@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0101.outbound.protection.outlook.com ([157.56.111.101]:22032
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751024AbbCKDMi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 23:12:38 -0400
In-Reply-To: <54FEEF00.3060201@Freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Emil,

> On 03/10/2015 05:31 AM, shh.xie@gmail.com wrote:
> > From: Shaohui Xie <Shaohui.Xie@freescale.com>
> >
> > FSL_PQ_MDIO and FSL_XGMAC_MDIO are not really depend on FSL_SOC, they
> > can build on non-PPC platforms.
> 
> FSL_SOC is already defined for some ARM-based SoC? Why don't you use/fix
> that.
[S.H] I grep on top of the net-next tree, only found the FSL_SOC defined in arch/powerpc/Kconfig.

 We have plenty of devices integrated on both SoC families...
> 
> Or are you targeting other non-PPC/ARM SoC(s)?
[S.H] the point is to remove the unnecessary dependency to make the driver can build ARCH independently, no matter what the SoC is.

Thanks!
Shaohui

> 
> 
> Cheers,
> 
> 
> > Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/Kconfig | 2 --
> >  1 file changed, 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/Kconfig
> > b/drivers/net/ethernet/freescale/Kconfig
> > index ba84c4a..25e3425 100644
> > --- a/drivers/net/ethernet/freescale/Kconfig
> > +++ b/drivers/net/ethernet/freescale/Kconfig
> > @@ -58,14 +58,12 @@ source
> "drivers/net/ethernet/freescale/fs_enet/Kconfig"
> >
> >  config FSL_PQ_MDIO
> >  	tristate "Freescale PQ MDIO"
> > -	depends on FSL_SOC
> >  	select PHYLIB
> >  	---help---
> >  	  This driver supports the MDIO bus used by the gianfar and UCC
> drivers.
> >
> >  config FSL_XGMAC_MDIO
> >  	tristate "Freescale XGMAC MDIO"
> > -	depends on FSL_SOC
> >  	select PHYLIB
> >  	select OF_MDIO
> >  	---help---
> >
