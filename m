From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 06/17] net: stmmac: fix some code style problem
Date: Tue, 31 Jan 2017 11:05:36 +0100
Message-ID: <cb26f8fe-ee50-6be9-cb40-defcdc1832e3@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-7-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:16999 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751239AbdAaKGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:06:23 -0500
In-Reply-To: <20170131091152.13842-7-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> Checkpatch complains about some code style problem on stmmac_mdio.c.
> This patch fix them.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 3fdc6ec..c24bef2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -152,9 +152,9 @@ int stmmac_mdio_reset(struct mii_bus *bus)
>
>  #ifdef CONFIG_OF
>  	if (priv->device->of_node) {
> -
>  		if (data->reset_gpio < 0) {
>  			struct device_node *np = priv->device->of_node;
> +
>  			if (!np)
>  				return 0;
>
> @@ -221,7 +221,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  		return 0;
>
>  	new_bus = mdiobus_alloc();
> -	if (new_bus == NULL)
> +	if (!new_bus)
>  		return -ENOMEM;
>
>  	if (mdio_bus_data->irqs)
> @@ -258,6 +258,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	found = 0;
>  	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
>  		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
> +
>  		if (phydev) {
>  			int act = 0;
>  			char irq_num[4];
> @@ -267,7 +268,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  			 * If an IRQ was provided to be assigned after
>  			 * the bus probe, do it here.
>  			 */
> -			if ((mdio_bus_data->irqs == NULL) &&
> +			if ((!mdio_bus_data->irqs) &&
>  			    (mdio_bus_data->probed_phy_irq > 0)) {
>  				new_bus->irq[addr] =
>  					mdio_bus_data->probed_phy_irq;
>
