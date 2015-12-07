From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] ethernet: aurora: AURORA_NB8800 should depend on HAS_DMA
Date: Mon,  7 Dec 2015 10:09:06 +0100
Message-ID: <1449479346-32601-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?q?M=C3=A5ns=20Rullg=C3=A5rd?= <mans@mansr.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

    ERROR: "dma_map_single" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_unmap_page" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_sync_single_for_cpu" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_unmap_single" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_alloc_coherent" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_mapping_error" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_map_page" [drivers/net/ethernet/aurora/nb8800.ko] undefined!
    ERROR: "dma_free_coherent" [drivers/net/ethernet/aurora/nb8800.ko] undefined!

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/aurora/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/aurora/Kconfig b/drivers/net/ethernet/aurora/Kconfig
index a3c7106fdf85e78f..8ba7f8ff3434000f 100644
--- a/drivers/net/ethernet/aurora/Kconfig
+++ b/drivers/net/ethernet/aurora/Kconfig
@@ -13,6 +13,7 @@ if NET_VENDOR_AURORA
 
 config AURORA_NB8800
 	tristate "Aurora AU-NB8800 support"
+	depends on HAS_DMA
 	select PHYLIB
 	help
 	 Support for the AU-NB8800 gigabit Ethernet controller.
-- 
1.9.1
