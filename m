From: Lars Persson <lars.persson@axis.com>
Subject: Re: [PATCH] ethernet: synopsys: SYNOPSYS_DWC_ETH_QOS should depend
 on HAS_DMA
Date: Fri, 4 Sep 2015 15:35:22 +0200
Message-ID: <1441373722.8749.3.camel@axis.com>
References: <1441370652-13762-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441370652-13762-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-09-04 at 14:44 +0200, Geert Uytterhoeven wrote:
> If NO_DMA=y:
> 
>     ERROR: "dma_alloc_coherent" [drivers/net/ethernet/synopsys/dwc_eth_qos.ko] undefined!
>     ERROR: "dma_free_coherent" [drivers/net/ethernet/synopsys/dwc_eth_qos.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/synopsys/dwc_eth_qos.ko] undefined!
>     ERROR: "dma_map_page" [drivers/net/ethernet/synopsys/dwc_eth_qos.ko] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/synopsys/dwc_eth_qos.ko] undefined!
>     ERROR: "dma_map_single" [drivers/net/ethernet/synopsys/dwc_eth_qos.ko] undefined!
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Lars Persson <larper@axis.com>

> ---
>  drivers/net/ethernet/synopsys/Kconfig | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/synopsys/Kconfig b/drivers/net/ethernet/synopsys/Kconfig
> index a8f315106742d9b1..8276ee5a7d541b2e 100644
> --- a/drivers/net/ethernet/synopsys/Kconfig
> +++ b/drivers/net/ethernet/synopsys/Kconfig
> @@ -20,7 +20,7 @@ config SYNOPSYS_DWC_ETH_QOS
>  	select PHYLIB
>  	select CRC32
>  	select MII
> -	depends on OF
> +	depends on OF && HAS_DMA
>  	---help---
>  	  This driver supports the DWC Ethernet QoS from Synopsys
>  
