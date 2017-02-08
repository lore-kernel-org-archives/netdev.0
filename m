From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2 13/16] net: stmmac: print phy information
Date: Wed, 8 Feb 2017 14:18:52 +0100
Message-ID: <bd9e2968-943f-693a-1376-8f6fa2703ec7@st.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
 <20170208083121.27949-14-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:17515 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933127AbdBHNTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 08:19:02 -0500
In-Reply-To: <20170208083121.27949-14-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/2017 9:31 AM, Corentin Labbe wrote:
> When a PHY is found, printing which one was found (and which type/model) is
> a good information to know.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index cc88bdb..9805aa8 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -870,9 +870,7 @@ static int stmmac_init_phy(struct net_device *dev)
>  	if (phydev->is_pseudo_fixed_link)
>  		phydev->irq = PHY_POLL;
>
> -	netdev_dbg(priv->dev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
> -		   __func__, phydev->phy_id, phydev->link);
> -
> +	phy_attached_info(phydev);
>  	return 0;
>  }
>
>
