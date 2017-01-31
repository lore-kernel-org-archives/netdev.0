From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 10/17] net: stmmac: Correct the error message about
 invalid speed
Date: Tue, 31 Jan 2017 11:07:19 +0100
Message-ID: <505d6fa5-852c-2c18-f940-964ee422d820@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-11-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:4038 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751507AbdAaKHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:07:30 -0500
In-Reply-To: <20170131091152.13842-11-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> Add 1000 as a valid speed in the error message about invalid speed
> in stmmac_adjust_link()
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 98f544e..b0154d5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -749,7 +749,7 @@ static void stmmac_adjust_link(struct net_device *dev)
>  				break;
>  			default:
>  				netif_warn(priv, link, priv->dev,
> -					   "Speed (%d) not 10/100\n",
> +					   "Speed (%d) not 10/100/1000\n",

maybe, it could be "broken speed: %d"

peppe

>  					   phydev->speed);
>  				break;
>  			}
>
