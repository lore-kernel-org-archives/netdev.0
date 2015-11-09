From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: hisilicon: NET_VENDOR_HISILICON should depend on HAS_DMA
Date: Mon, 09 Nov 2015 10:46:34 +0100
Message-ID: <6095433.PbGKVamcAs@wuerfel>
References: <1447061670-19681-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	huangdaode <huangdaode@hisilicon.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:60376 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417AbbKIJv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 04:51:57 -0500
In-Reply-To: <1447061670-19681-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 09 November 2015 10:34:30 Geert Uytterhoeven wrote:
> If NO_DMA=y:
> 
>     ERROR: "dma_set_mask" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_unmap_page" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_map_page" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_supported" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hns/hns_enet_drv.ko] undefined!
>     ERROR: "dma_set_mask" [drivers/net/ethernet/hisilicon/hns/hns_dsaf.ko] undefined!
>     ERROR: "dma_supported" [drivers/net/ethernet/hisilicon/hns/hns_dsaf.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
>     ERROR: "dma_unmap_page" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
>     ERROR: "dma_map_page" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
>     ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hns/hnae.ko] undefined!
>     ERROR: "dma_alloc_coherent" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
>     ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
>     ERROR: "dma_free_coherent" [drivers/net/ethernet/hisilicon/hix5hd2_gmac.ko] undefined!
>     ERROR: "dma_alloc_coherent" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
>     ERROR: "dma_mapping_error" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
>     ERROR: "dma_map_single" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
>     ERROR: "dma_unmap_single" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
>     ERROR: "dma_free_coherent" [drivers/net/ethernet/hisilicon/hip04_eth.ko] undefined!
> 
> As this affects all of HNS_ENET, HNS_DSAF, HNS, HIX5HD2_GMAC, and
> HIP04_ETH, add a dependency on HAS_DMA to the main NET_VENDOR_HISILICON
> symbol to fix this.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> 

Acked-by: Arnd Bergmann <arnd@arndb.de>
