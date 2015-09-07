From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet: synopsys: SYNOPSYS_DWC_ETH_QOS should depend
 on HAS_DMA
Date: Sun, 06 Sep 2015 19:49:05 -0700 (PDT)
Message-ID: <20150906.194905.419813231277668681.davem@davemloft.net>
References: <1441370652-13762-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441370652-13762-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri,  4 Sep 2015 14:44:12 +0200

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

Applied, thanks.
