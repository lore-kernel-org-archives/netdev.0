From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: aurora: AURORA_NB8800 should depend on
 HAS_DMA
Date: Mon, 07 Dec 2015 13:55:29 -0500 (EST)
Message-ID: <20151207.135529.1339848644773209220.davem@davemloft.net>
References: <1449479346-32601-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mans@mansr.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449479346-32601-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon,  7 Dec 2015 10:09:06 +0100

> If NO_DMA=y:
> 
>     ERROR: "dma_map_single" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_unmap_page" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_alloc_coherent" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_map_page" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
>     ERROR: "dma_free_coherent" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks Geert.
