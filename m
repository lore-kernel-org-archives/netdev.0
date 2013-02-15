From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v2] Prevent interrupt loop with DWMAC MMC RX IPC Counter
Date: Fri, 15 Feb 2013 16:18:01 +0100
Message-ID: <511E51A9.9020908@st.com>
References: <20130215144815.GA31098@ab42.lan> <1360940282-27211-1-git-send-email-christian.ruppert@abilis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>
To: Christian Ruppert <christian.ruppert@abilis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360940282-27211-1-git-send-email-christian.ruppert@abilis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/15/2013 3:58 PM, Christian Ruppert wrote:
> If the DesignWare MAC is synthesised with MMC RX IPC Counter, an unmanaged
> and unacknowledged interrupt is generated after some time of operation.
>
> This patch masks the undesired interrupts.
>
> Signed-off-by: Christian Ruppert <christian.ruppert@abilis.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>   drivers/net/ethernet/stmicro/stmmac/mmc_core.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
> index 0c74a70..50617c5 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/mmc_core.c
> @@ -149,6 +149,7 @@ void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
>   {
>   	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_INTR_MASK);
>   	writel(MMC_DEFAULT_MASK, ioaddr + MMC_TX_INTR_MASK);
> +	writel(MMC_DEFAULT_MASK, ioaddr + MMC_RX_IPC_INTR_MASK);
>   }
>
>   /* This reads the MAC core counters (if actaully supported).
>
