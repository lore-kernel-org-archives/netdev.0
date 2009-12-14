From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 2/4] mx25: don't force input on FEC pins
Date: Mon, 14 Dec 2009 12:19:40 +0200
Message-ID: <a7c4a6919d5687cefa6ad12fb8bf2b08733823da.1260785451.git.baruch@tkos.co.il>
References: <cover.1260785451.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Baruch Siach <baruch@tkos.co.il>,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <kernel@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1260785451.git.baruch@tkos.co.il>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 arch/arm/plat-mxc/include/mach/iomux-mx25.h |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/arch/arm/plat-mxc/include/mach/iomux-mx25.h b/arch/arm/plat-mxc/include/mach/iomux-mx25.h
index 9af494f..d7c0dea 100644
--- a/arch/arm/plat-mxc/include/mach/iomux-mx25.h
+++ b/arch/arm/plat-mxc/include/mach/iomux-mx25.h
@@ -54,7 +54,7 @@
 #define MX25_PAD_A16__GPIO_2_2		IOMUX_PAD(0x000, 0x018, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A17__A17		IOMUX_PAD(0x238, 0x01c, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A17__GPIO_2_3		IOMUX_PAD(0x238, 0x01c, 0x15, 0, 0, NO_PAD_CTRL)
+#define MX25_PAD_A17__GPIO_2_3		IOMUX_PAD(0x238, 0x01c, 0x05, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A18__A18		IOMUX_PAD(0x23c, 0x020, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A18__GPIO_2_4		IOMUX_PAD(0x23c, 0x020, 0x15, 0, 0, NO_PAD_CTRL)
@@ -410,35 +410,35 @@
 #define MX25_PAD_KPP_COL3__KPP_COL3	IOMUX_PAD(0x3bc, 0x1c4, 0x10, 0, 0, PAD_CTL_PKE | PAD_CTL_ODE)
 #define MX25_PAD_KPP_COL3__GPIO_3_4	IOMUX_PAD(0x3bc, 0x1c4, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_MDC__FEC_MDC	IOMUX_PAD(0x3c0, 0x1c8, 0x10, 0, 0, NO_PAD_CTRL)
+#define MX25_PAD_FEC_MDC__FEC_MDC	IOMUX_PAD(0x3c0, 0x1c8, 0x00, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_MDC__AUD4_TXD	IOMUX_PAD(0x3c0, 0x1c8, 0x12, 0x464, 1, NO_PAD_CTRL)
 #define MX25_PAD_FEC_MDC__GPIO_3_5	IOMUX_PAD(0x3c0, 0x1c8, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_MDIO__FEC_MDIO	IOMUX_PAD(0x3c4, 0x1cc, 0x10, 0, 0, PAD_CTL_HYS | PAD_CTL_PUS_22K_UP)
+#define MX25_PAD_FEC_MDIO__FEC_MDIO	IOMUX_PAD(0x3c4, 0x1cc, 0x00, 0, 0, PAD_CTL_HYS | PAD_CTL_PUS_22K_UP)
 #define MX25_PAD_FEC_MDIO__AUD4_RXD	IOMUX_PAD(0x3c4, 0x1cc, 0x12, 0x460, 1, NO_PAD_CTRL)
 #define MX25_PAD_FEC_MDIO__GPIO_3_6	IOMUX_PAD(0x3c4, 0x1cc, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TDATA0__FEC_TDATA0	IOMUX_PAD(0x3c8, 0x1d0, 0x10, 0, 0, NO_PAD_CTRL)
+#define MX25_PAD_FEC_TDATA0__FEC_TDATA0	IOMUX_PAD(0x3c8, 0x1d0, 0x00, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TDATA0__GPIO_3_7	IOMUX_PAD(0x3c8, 0x1d0, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TDATA1__FEC_TDATA1	IOMUX_PAD(0x3cc, 0x1d4, 0x10, 0, 0, NO_PAD_CTRL)
+#define MX25_PAD_FEC_TDATA1__FEC_TDATA1	IOMUX_PAD(0x3cc, 0x1d4, 0x00, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TDATA1__AUD4_TXFS	IOMUX_PAD(0x3cc, 0x1d4, 0x12, 0x474, 1, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TDATA1__GPIO_3_8	IOMUX_PAD(0x3cc, 0x1d4, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TX_EN__FEC_TX_EN	IOMUX_PAD(0x3d0, 0x1d8, 0x10, 0, 0, NO_PAD_CTRL)
+#define MX25_PAD_FEC_TX_EN__FEC_TX_EN	IOMUX_PAD(0x3d0, 0x1d8, 0x00, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TX_EN__GPIO_3_9   	IOMUX_PAD(0x3d0, 0x1d8, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_RDATA0__FEC_RDATA0	IOMUX_PAD(0x3d4, 0x1dc, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
+#define MX25_PAD_FEC_RDATA0__FEC_RDATA0	IOMUX_PAD(0x3d4, 0x1dc, 0x00, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
 #define MX25_PAD_FEC_RDATA0__GPIO_3_10	IOMUX_PAD(0x3d4, 0x1dc, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_RDATA1__FEC_RDATA1	IOMUX_PAD(0x3d8, 0x1e0, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
+#define MX25_PAD_FEC_RDATA1__FEC_RDATA1	IOMUX_PAD(0x3d8, 0x1e0, 0x00, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
 #define MX25_PAD_FEC_RDATA1__GPIO_3_11	IOMUX_PAD(0x3d8, 0x1e0, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_RX_DV__FEC_RX_DV	IOMUX_PAD(0x3dc, 0x1e4, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
+#define MX25_PAD_FEC_RX_DV__FEC_RX_DV	IOMUX_PAD(0x3dc, 0x1e4, 0x00, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
 #define MX25_PAD_FEC_RX_DV__CAN2_RX	IOMUX_PAD(0x3dc, 0x1e4, 0x14, 0x484, 0, PAD_CTL_PUS_22K_UP)
 #define MX25_PAD_FEC_RX_DV__GPIO_3_12	IOMUX_PAD(0x3dc, 0x1e4, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TX_CLK__FEC_TX_CLK	IOMUX_PAD(0x3e0, 0x1e8, 0x10, 0, 0, PAD_CTL_HYS | PAD_CTL_PUS_100K_DOWN)
+#define MX25_PAD_FEC_TX_CLK__FEC_TX_CLK	IOMUX_PAD(0x3e0, 0x1e8, 0x00, 0, 0, PAD_CTL_HYS | PAD_CTL_PUS_100K_DOWN)
 #define MX25_PAD_FEC_TX_CLK__GPIO_3_13	IOMUX_PAD(0x3e0, 0x1e8, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_RTCK__RTCK		IOMUX_PAD(0x3e4, 0x1ec, 0x10, 0, 0, NO_PAD_CTRL)
-- 
1.6.5
