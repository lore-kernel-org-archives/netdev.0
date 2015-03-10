From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: Re: [linuxppc-release] [PATCH] net/fsl: remove dependency FSL_SOC
 from MDIO
Date: Tue, 10 Mar 2015 08:17:52 -0500
Message-ID: <54FEEF00.3060201@Freescale.com>
References: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Shaohui Xie <Shaohui.Xie@Freescale.com>,
	Scott Wood <scottwood@Freescale.com>
To: <shh.xie@gmail.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0135.outbound.protection.outlook.com ([157.56.111.135]:12352
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751390AbbCJNOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 09:14:49 -0400
In-Reply-To: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Shao-Hui,


On 03/10/2015 05:31 AM, shh.xie@gmail.com wrote:
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
> 
> FSL_PQ_MDIO and FSL_XGMAC_MDIO are not really depend on FSL_SOC, they
> can build on non-PPC platforms.

FSL_SOC is already defined for some ARM-based SoC? Why don't you use/fix
that. We have plenty of devices integrated on both SoC families...

Or are you targeting other non-PPC/ARM SoC(s)?


Cheers,


> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/ethernet/freescale/Kconfig | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
> index ba84c4a..25e3425 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -58,14 +58,12 @@ source "drivers/net/ethernet/freescale/fs_enet/Kconfig"
>  
>  config FSL_PQ_MDIO
>  	tristate "Freescale PQ MDIO"
> -	depends on FSL_SOC
>  	select PHYLIB
>  	---help---
>  	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
>  
>  config FSL_XGMAC_MDIO
>  	tristate "Freescale XGMAC MDIO"
> -	depends on FSL_SOC
>  	select PHYLIB
>  	select OF_MDIO
>  	---help---
> 
