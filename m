From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: fixed operator typo
Date: Fri, 28 Jun 2013 14:59:36 +0200
Message-ID: <51CD88B8.6050209@st.com>
References: <015701ce73d2$117b9040$3472b0c0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?EUC-KR?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:60360 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753103Ab3F1N27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 09:28:59 -0400
In-Reply-To: <015701ce73d2$117b9040$3472b0c0$%an@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/2013 9:35 AM, Byungho An wrote:
> 
> This patch fixed operator typo from & to ==.
> Due to incorrect operator, the result is incorrect.
> 
> Signed-off-by: Byungho An <bh74.an@samsung.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   22 +++++++++++++--------
>   1 file changed, 14 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index c1ad5f4..f088633 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -788,13 +788,13 @@ static void stmmac_check_pcs_mode(struct stmmac_priv *priv)
>   	int interface = priv->plat->interface;
>   
>   	if (priv->dma_cap.pcs) {
> -		if ((interface & PHY_INTERFACE_MODE_RGMII) ||
> -		    (interface & PHY_INTERFACE_MODE_RGMII_ID) ||
> -		    (interface & PHY_INTERFACE_MODE_RGMII_RXID) ||
> -		    (interface & PHY_INTERFACE_MODE_RGMII_TXID)) {
> +		if ((interface == PHY_INTERFACE_MODE_RGMII) ||
> +		    (interface == PHY_INTERFACE_MODE_RGMII_ID) ||
> +		    (interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
> +		    (interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
>   			pr_debug("STMMAC: PCS RGMII support enable\n");
>   			priv->pcs = STMMAC_PCS_RGMII;
> -		} else if (interface & PHY_INTERFACE_MODE_SGMII) {
> +		} else if (interface == PHY_INTERFACE_MODE_SGMII) {
>   			pr_debug("STMMAC: PCS SGMII support enable\n");
>   			priv->pcs = STMMAC_PCS_SGMII;
>   		}
> 
