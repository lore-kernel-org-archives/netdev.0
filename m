From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: simplify flag assignment
Date: Fri, 2 Dec 2016 09:27:05 +0100
Message-ID: <7848a23a-7faa-be47-3c2c-da6880b2b909@st.com>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161130114431.GB14296@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Alexandre TORGUE <alexandre.torgue@st.com>
To: Pavel Machek <pavel@ucw.cz>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130114431.GB14296@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+ Alex

On 11/30/2016 12:44 PM, Pavel Machek wrote:
>
> Simplify flag assignment.
>
> Signed-off-by: Pavel Machek <pavel@denx.de>
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index ed20668..0b706a7 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -2771,12 +2771,8 @@ static netdev_features_t stmmac_fix_features(struct net_device *dev,
>  		features &= ~NETIF_F_CSUM_MASK;
>
>  	/* Disable tso if asked by ethtool */
> -	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen)) {
> -		if (features & NETIF_F_TSO)
> -			priv->tso = true;
> -		else
> -			priv->tso = false;
> -	}
> +	if ((priv->plat->tso_en) && (priv->dma_cap.tsoen))
> +		priv->tso = !!(features & NETIF_F_TSO);
>
>  	return features;
>  }
>
>
