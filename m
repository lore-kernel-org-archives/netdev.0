From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] macb: Use semicolon instead of comma for statement
Date: Sat, 12 Apr 2008 03:01:56 -0400
Message-ID: <48005E64.1090401@garzik.org>
References: <20080412.005814.26099357.anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Haavard Skinnemoen <hskinnemoen@atmel.com>, netdev@vger.kernel.org
To: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37701 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbYDLHCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 03:02:05 -0400
In-Reply-To: <20080412.005814.26099357.anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Atsushi Nemoto wrote:
> It seems no good reason to use comma here.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
> ---
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 1d210ed..0881690 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -242,12 +242,12 @@ static int macb_mii_init(struct macb *bp)
>  	/* Enable managment port */
>  	macb_writel(bp, NCR, MACB_BIT(MPE));
>  
> -	bp->mii_bus.name = "MACB_mii_bus",
> -	bp->mii_bus.read = &macb_mdio_read,
> -	bp->mii_bus.write = &macb_mdio_write,
> -	bp->mii_bus.reset = &macb_mdio_reset,
> -	bp->mii_bus.id = bp->pdev->id,
> -	bp->mii_bus.priv = bp,
> +	bp->mii_bus.name = "MACB_mii_bus";
> +	bp->mii_bus.read = &macb_mdio_read;
> +	bp->mii_bus.write = &macb_mdio_write;
> +	bp->mii_bus.reset = &macb_mdio_reset;
> +	bp->mii_bus.id = bp->pdev->id;
> +	bp->mii_bus.priv = bp;
>  	bp->mii_bus.dev = &bp->dev->dev;
>  	pdata = bp->pdev->dev.platform_data;
>  

applied


