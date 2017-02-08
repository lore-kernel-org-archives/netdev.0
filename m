From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 06/16] net: stmmac: fix some code style problem
Date: Wed, 8 Feb 2017 14:57:20 +0300
Message-ID: <2b6652d7-6a5c-ab68-2e74-c6e83f12a87a@cogentembedded.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
 <20170208083121.27949-7-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34197 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932096AbdBHMEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 07:04:42 -0500
Received: by mail-lf0-f52.google.com with SMTP id v186so80641555lfa.1
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 04:04:36 -0800 (PST)
In-Reply-To: <20170208083121.27949-7-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 2/8/2017 11:31 AM, Corentin Labbe wrote:

> Checkpatch complains about some code style problem on stmmac_mdio.c.
> This patch fix them.

    Fixes.

> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 3fdc6ec..c24bef2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
[...]
> @@ -267,7 +268,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  			 * If an IRQ was provided to be assigned after
>  			 * the bus probe, do it here.
>  			 */
> -			if ((mdio_bus_data->irqs == NULL) &&
> +			if ((!mdio_bus_data->irqs) &&

    Innermost parens not needed (and weren't needed before).

>  			    (mdio_bus_data->probed_phy_irq > 0)) {
>  				new_bus->irq[addr] =
>  					mdio_bus_data->probed_phy_irq;

MBR, Sergei
