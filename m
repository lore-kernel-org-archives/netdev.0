From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] net: stmmac: Add additional registers for dwmac1000_dma
 ethtool
Date: Wed, 28 Jun 2017 11:01:17 +0200
Message-ID: <797e7262-aa88-cacc-5b85-3d8583f6537d@st.com>
References: <1498601787-17390-1-git-send-email-thor.thayer@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <thor.thayer@linux.intel.com>, <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:16987 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751787AbdF1JRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 05:17:51 -0400
In-Reply-To: <1498601787-17390-1-git-send-email-thor.thayer@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/28/2017 12:16 AM, thor.thayer@linux.intel.com wrote:
> From: Thor Thayer <thor.thayer@linux.intel.com>
>
> Version 3.70a of the Designware has additional DMA registers so
> add those to the ethtool DMA Register dump.
> Offset 9  - Receive Interrupt Watchdog Timer Register
> Offset 10 - AXI Bus Mode Register
> Offset 11 - AHB or AXI Status Register
> Offset 22 - HW Feature Register
>
> Signed-off-by: Thor Thayer <thor.thayer@linux.intel.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c  | 4 ++--
>   drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 2 +-
>   2 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> index 471a9aa..22cf635 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
> @@ -205,8 +205,8 @@ static void dwmac1000_dump_dma_regs(void __iomem *ioaddr, u32 *reg_space)
>   {
>   	int i;
>   
> -	for (i = 0; i < 22; i++)
> -		if ((i < 9) || (i > 17))
> +	for (i = 0; i < 23; i++)
> +		if ((i < 12) || (i > 17))
>   			reg_space[DMA_BUS_MODE / 4 + i] =
>   				readl(ioaddr + DMA_BUS_MODE + i * 4);
>   }
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> index 743170d..babb39c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
> @@ -29,7 +29,7 @@
>   #include "stmmac.h"
>   #include "dwmac_dma.h"
>   
> -#define REG_SPACE_SIZE	0x1054
> +#define REG_SPACE_SIZE	0x1060
>   #define MAC100_ETHTOOL_NAME	"st_mac100"
>   #define GMAC_ETHTOOL_NAME	"st_gmac"
>   
