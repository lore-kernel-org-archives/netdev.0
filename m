From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 02/18] stmmac: rework DMA bus setting
 and introduce new platform AXI structure
Date: Mon, 04 Jan 2016 22:29:55 -0500 (EST)
Message-ID: <20160104.222955.94740482244105696.davem@davemloft.net>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
	<1451912823-5245-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51064 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbcAED35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:29:57 -0500
In-Reply-To: <1451912823-5245-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 4 Jan 2016 14:06:47 +0100

> @@ -81,7 +81,7 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
>  	plat->mdio_bus_data->phy_mask = 0;
>  
>  	plat->dma_cfg->pbl = 32;
> -	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
> +	/* TODO: AXI */
>  
>  	/* Set default value for multicast hash bins */
>  	plat->multicast_filter_bins = HASH_TABLE_SIZE;
> @@ -115,8 +115,8 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
>  	plat->mdio_bus_data->phy_mask = 0;
>  
>  	plat->dma_cfg->pbl = 16;
> -	plat->dma_cfg->burst_len = DMA_AXI_BLEN_256;
>  	plat->dma_cfg->fixed_burst = 1;
> +	/* AXI (TODO) */
>  
>  	/* Set default value for multicast hash bins */
>  	plat->multicast_filter_bins = HASH_TABLE_SIZE;

Isn't this going to cause a regression for some things?
