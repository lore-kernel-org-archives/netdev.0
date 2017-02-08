From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2 10/16] net: stmmac: Correct the error message about
 invalid speed
Date: Wed, 8 Feb 2017 14:18:20 +0100
Message-ID: <d5a0fb63-4f16-d431-5638-7ced4d28a8f9@st.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
 <20170208083121.27949-11-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:59090 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932242AbdBHNS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 08:18:29 -0500
In-Reply-To: <20170208083121.27949-11-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/2017 9:31 AM, Corentin Labbe wrote:
> The message about invalid speed does not state 1000 as a valid speed.
> It is much simpler to said that the speed is invalid.
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index a13fcc4..ed81375 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -738,8 +738,7 @@ static void stmmac_adjust_link(struct net_device *dev)
>  				break;
>  			default:
>  				netif_warn(priv, link, priv->dev,
> -					   "Speed (%d) not 10/100\n",
> -					   phydev->speed);
> +					   "broken speed: %d\n", phydev->speed);
>  				break;
>  			}
>
>
