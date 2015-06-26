From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: via: VIA_RHINE and VIA_VELOCITY should depend on
 HAS_DMA
Date: Fri, 26 Jun 2015 16:21:24 +0300
Message-ID: <558D51D4.9060202@cogentembedded.com>
References: <1435320502-4951-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>,
	Antonio Borneo <borneo.antonio@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435320502-4951-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 6/26/2015 3:08 PM, Geert Uytterhoeven wrote:

> If NO_DMA=y:

>      ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_set_mask" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_mapping_error" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_map_single" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_alloc_coherent" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_free_coherent" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_unmap_single" [drivers/net/ethernet/via/via-rhine.ko] undefined!
>      ERROR: "dma_map_page" [drivers/net/ethernet/via/via-velocity.ko] undefined!
>      ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/via/via-velocity.ko] undefined!
>      ERROR: "dma_free_coherent" [drivers/net/ethernet/via/via-velocity.ko] undefined!
>      ERROR: "dma_unmap_single" [drivers/net/ethernet/via/via-velocity.ko] undefined!
>      ERROR: "dma_map_single" [drivers/net/ethernet/via/via-velocity.ko] undefined!
>      ERROR: "dma_alloc_coherent" [drivers/net/ethernet/via/via-velocity.ko] undefined!

> Before, the symbols depended implicitly on HAS_DMA through PCI or
> USE_OF.  Add explicit dependencies on HAS_DMA to fix this.

> Fixes: commit b7d3282a245f4428 ("net: via/Kconfig: replace USE_OF with OF_???")

Fixes: b7d3282a245f ("net: via/Kconfig: replace USE_OF with OF_???")

> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

WBR, Sergei
