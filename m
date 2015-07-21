From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: fec: use managed DMA API functions to
 allocate BD ring
Date: Tue, 21 Jul 2015 00:32:51 -0700 (PDT)
Message-ID: <20150721.003251.609707799765780058.davem@davemloft.net>
References: <1437400298-17379-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@freescale.com, Frank.Li@freescale.com,
	netdev@vger.kernel.org, kernel@pengutronix.de,
	patchwork-lst@pengutronix.de
To: l.stach@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56201 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbbGUHcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:32:51 -0400
In-Reply-To: <1437400298-17379-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <l.stach@pengutronix.de>
Date: Mon, 20 Jul 2015 15:51:37 +0200

> So it gets freed when the device is going away.
> This fixes a DMA memory leak on driver probe() fail and driver
> remove().
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 349365d85b92..b3287c6b069b 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3142,7 +3142,7 @@ static int fec_enet_init(struct net_device *ndev)
>  			fep->bufdesc_size;
>  
>  	/* Allocate memory for buffer descriptors. */
> -	cbd_base = dma_alloc_coherent(NULL, bd_size, &bd_dma,
> +	cbd_base = dmam_alloc_coherent(&fep->pdev->dev, bd_size, &bd_dma,
>  				      GFP_KERNEL);

When you change the column of the openning parenthesis of a function call, you
must fix up the indentation of the second and subsequent lines so that they all
properly start at the first column after that openning parenthesis.
