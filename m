From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 01/16] net: stmmac: fix the typo on MAC_RNABLE_RX
Date: Wed,  8 Feb 2017 09:31:06 +0100
Message-ID: <20170208083121.27949-2-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

the define MAC_RNABLE_RX have a typo, rename it to MAC_ENABLE_RX

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h    | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 75e2666..262a1c4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -343,7 +343,7 @@ struct dma_features {
 /* Common MAC defines */
 #define MAC_CTRL_REG		0x00000000	/* MAC Control */
 #define MAC_ENABLE_TX		0x00000008	/* Transmitter Enable */
-#define MAC_RNABLE_RX		0x00000004	/* Receiver Enable */
+#define MAC_ENABLE_RX		0x00000004	/* Receiver Enable */
 
 /* Default LPI timers */
 #define STMMAC_DEFAULT_LIT_LS	0x3E8
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
index 84e3e84..a414bde 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
@@ -261,9 +261,9 @@ void stmmac_set_mac(void __iomem *ioaddr, bool enable)
 	u32 value = readl(ioaddr + MAC_CTRL_REG);
 
 	if (enable)
-		value |= MAC_RNABLE_RX | MAC_ENABLE_TX;
+		value |= MAC_ENABLE_RX | MAC_ENABLE_TX;
 	else
-		value &= ~(MAC_ENABLE_TX | MAC_RNABLE_RX);
+		value &= ~(MAC_ENABLE_TX | MAC_ENABLE_RX);
 
 	writel(value, ioaddr + MAC_CTRL_REG);
 }
-- 
2.10.2
