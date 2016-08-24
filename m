From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH v2] net: macb: Increase DMA TX buffer size
Date: Wed, 24 Aug 2016 17:25:39 -0500
Message-ID: <1472077539-18033-1-git-send-email-xander.huff@ni.com>
References: <cccfc176-df56-4add-e6c8-e040f9da31dc@atmel.com>
Cc: netdev@vger.kernel.org, Nathan Sullivan <nathan.sullivan@ni.com>,
        linux-kernel@vger.kernel.org, xander.huff@ni.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cccfc176-df56-4add-e6c8-e040f9da31dc@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>

In recent testing with the RT patchset, we have seen cases where the
transmit ring can fill even with up to 200 txbds in the ring. Increase the
size of the DMA TX ring to avoid overruns.

Signed-off-by: Xander Huff <xander.huff@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3256839..3efddb7 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -40,7 +40,7 @@
 #define RX_RING_SIZE		512 /* must be power of 2 */
 #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
 
-#define TX_RING_SIZE		128 /* must be power of 2 */
+#define TX_RING_SIZE		512 /* must be power of 2 */
 #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
 
 /* level of occupied TX descriptors under which we wake up TX process */
-- 
1.9.1
