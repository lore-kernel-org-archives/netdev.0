From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH v2 4/6] net: stmmac: dwmac1000: fix define DMA_BUS_MODE_RPBL_MASK
Date: Mon, 5 Dec 2016 10:10:36 +0100
Message-ID: <1480929039-20257-5-git-send-email-niklass@axis.com>
References: <1480929039-20257-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480929039-20257-1-git-send-email-niklass@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Cassel <niklas.cassel@axis.com>

DMA_BUS_MODE_RPBL_MASK is really 6 bits,
just like DMA_BUS_MODE_PBL_MASK.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index ff3e5ab39bd0..52b9407a8a39 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -225,7 +225,7 @@ enum rx_tx_priority_ratio {
 
 #define DMA_BUS_MODE_FB		0x00010000	/* Fixed burst */
 #define DMA_BUS_MODE_MB		0x04000000	/* Mixed burst */
-#define DMA_BUS_MODE_RPBL_MASK	0x003e0000	/* Rx-Programmable Burst Len */
+#define DMA_BUS_MODE_RPBL_MASK	0x007e0000	/* Rx-Programmable Burst Len */
 #define DMA_BUS_MODE_RPBL_SHIFT	17
 #define DMA_BUS_MODE_USP	0x00800000
 #define DMA_BUS_MODE_MAXPBL	0x01000000
-- 
2.1.4
