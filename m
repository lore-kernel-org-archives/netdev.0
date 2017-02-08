From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2 02/16] net: stmmac: Remove the bus_setup function
 pointer
Date: Wed, 8 Feb 2017 14:17:14 +0100
Message-ID: <1ca83b31-3c14-b8d1-18e8-a1c920053589@st.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
 <20170208083121.27949-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:53168 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932288AbdBHNRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 08:17:23 -0500
In-Reply-To: <20170208083121.27949-3-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/2017 9:31 AM, Corentin Labbe wrote:
> The bus_setup function pointer is not used at all, this patch remove it.
>
                                     no longer used...


> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ----
>  include/linux/stmmac.h                            | 1 -
>  2 files changed, 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index bd83bf9..1ef60282 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1682,10 +1682,6 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
>  	/* Copy the MAC addr into the HW  */
>  	priv->hw->mac->set_umac_addr(priv->hw, dev->dev_addr, 0);
>
> -	/* If required, perform hw setup of the bus. */
> -	if (priv->plat->bus_setup)
> -		priv->plat->bus_setup(priv->ioaddr);
> -
>  	/* PS and related bits will be programmed according to the speed */
>  	if (priv->hw->pcs) {
>  		int speed = priv->plat->mac_port_sel_speed;
> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
> index d76033d6..fc273e9 100644
> --- a/include/linux/stmmac.h
> +++ b/include/linux/stmmac.h
> @@ -134,7 +134,6 @@ struct plat_stmmacenet_data {
>  	int tx_fifo_size;
>  	int rx_fifo_size;
>  	void (*fix_mac_speed)(void *priv, unsigned int speed);
> -	void (*bus_setup)(void __iomem *ioaddr);
>  	int (*init)(struct platform_device *pdev, void *priv);
>  	void (*exit)(struct platform_device *pdev, void *priv);
>  	void *bsp_priv;
>
