From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 01/17] net: stmmac: fix the typo on MAC_RNABLE_RX
Date: Tue, 31 Jan 2017 11:03:11 +0100
Message-ID: <d518783e-5734-9fbf-d707-ca1b9a809535@st.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
 <20170131091152.13842-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Corentin Labbe <clabbe.montjoie@gmail.com>,
        <alexandre.torgue@st.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:31395 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-FAIL-OK-OK)
        by vger.kernel.org with ESMTP id S1750804AbdAaKFr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 05:05:47 -0500
In-Reply-To: <20170131091152.13842-2-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/31/2017 10:11 AM, Corentin Labbe wrote:
> the define MAC_RNABLE_RX have a typo, rename it to MAC_ENABLE_RX
>
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/common.h    | 2 +-
>  drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
> index b13a144..0f90f91 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> @@ -340,7 +340,7 @@ struct dma_features {
>  /* Common MAC defines */
>  #define MAC_CTRL_REG		0x00000000	/* MAC Control */
>  #define MAC_ENABLE_TX		0x00000008	/* Transmitter Enable */
> -#define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
> +#define MAC_ENABLE_RX		0x00000004	/* Receiver Enable */
>
>  /* Default LPI timers */
>  #define STMMAC_DEFAULT_LIT_LS	0x3E8
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> index 84e3e84..a414bde 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
> @@ -261,9 +261,9 @@ void stmmac_set_mac(void __iomem *ioaddr, bool enable)
>  	u32 value = readl(ioaddr + MAC_CTRL_REG);
>
>  	if (enable)
> -		value |= MAC_RNABLE_RX | MAC_ENABLE_TX;
> +		value |= MAC_ENABLE_RX | MAC_ENABLE_TX;
>  	else
> -		value &= ~(MAC_ENABLE_TX | MAC_RNABLE_RX);
> +		value &= ~(MAC_ENABLE_TX | MAC_ENABLE_RX);
>
>  	writel(value, ioaddr + MAC_CTRL_REG);
>  }
>
