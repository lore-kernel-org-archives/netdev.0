From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 3/3] ath10k: ATH10K should depend on HAS_DMA
Date: Wed, 10 Jul 2013 23:03:36 +0200
Message-ID: <1373490216-12437-3-git-send-email-geert@linux-m68k.org>
References: <1373490216-12437-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-wireless@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373490216-12437-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If NO_DMA=y:

drivers/built-in.o: In function `ath10k_skb_unmap':
drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath10k_skb_map':
drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath10k_htt_rx_ring_free':
drivers/net/wireless/ath/ath10k/htt_rx.c:113: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath10k_htt_rx_amsdu_pop':
drivers/net/wireless/ath/ath10k/htt_rx.c:296: undefined reference to `dma_unmap_single'
drivers/net/wireless/ath/ath10k/htt_rx.c:389: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `__ath10k_htt_rx_ring_fill_n':
drivers/net/wireless/ath/ath10k/htt_rx.c:146: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath10k/htt_rx.c:150: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath10k_htt_rx_attach':
drivers/net/wireless/ath/ath10k/htt_rx.c:474: undefined reference to `dma_alloc_coherent'
drivers/net/wireless/ath/ath10k/htt_rx.c:509: undefined reference to `dma_free_coherent'
drivers/net/wireless/ath/ath10k/htt_rx.c:514: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `ath10k_htt_rx_detach':
drivers/net/wireless/ath/ath10k/htt_rx.c:220: undefined reference to `dma_unmap_single'
drivers/net/wireless/ath/ath10k/htt_rx.c:228: undefined reference to `dma_free_coherent'
drivers/built-in.o: In function `ath10k_skb_map':
drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath10k_skb_unmap':
drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
drivers/built-in.o: In function `ath10k_skb_map':
drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
drivers/net/wireless/ath/ath10k/core.h:83: undefined reference to `dma_map_single'
drivers/net/wireless/ath/ath10k/core.h:86: undefined reference to `dma_mapping_error'
drivers/built-in.o: In function `ath10k_skb_unmap':
drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'
drivers/net/wireless/ath/ath10k/core.h:98: undefined reference to `dma_unmap_single'

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-wireless@vger.kernel.org
---
 drivers/net/wireless/ath/ath10k/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath10k/Kconfig b/drivers/net/wireless/ath/ath10k/Kconfig
index cde58fe..82e8088 100644
--- a/drivers/net/wireless/ath/ath10k/Kconfig
+++ b/drivers/net/wireless/ath/ath10k/Kconfig
@@ -1,6 +1,6 @@
 config ATH10K
         tristate "Atheros 802.11ac wireless cards support"
-        depends on MAC80211
+        depends on MAC80211 && HAS_DMA
 	select ATH_COMMON
         ---help---
           This module adds support for wireless adapters based on
-- 
1.7.9.5
