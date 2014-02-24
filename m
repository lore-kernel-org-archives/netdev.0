From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: Check return value of alloc_dma_desc_resources()
Date: Mon, 24 Feb 2014 16:22:08 +0100
Message-ID: <530B63A0.902@st.com>
References: <1393070943-3466-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:56264 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752421AbaBXPW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 10:22:27 -0500
In-Reply-To: <1393070943-3466-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/22/2014 1:09 PM, Tobias Klauser wrote:
> alloc_dma_desc_resources() returns an error value and the next line
> actually checks for it, so assign the return value properly.
>
> Found by the coverity scanner.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index a2e7d2c..078ad0e 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -1705,7 +1705,7 @@ static int stmmac_open(struct net_device *dev)
>   	priv->dma_rx_size = STMMAC_ALIGN(dma_rxsize);
>   	priv->dma_buf_sz = STMMAC_ALIGN(buf_sz);
>
> -	alloc_dma_desc_resources(priv);
> +	ret = alloc_dma_desc_resources(priv);
>   	if (ret < 0) {
>   		pr_err("%s: DMA descriptors allocation failed\n", __func__);
>   		goto dma_desc_error;
>
