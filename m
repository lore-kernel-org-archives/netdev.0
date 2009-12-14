From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH 1/4] mx25: s/NO_PAD_CTL/NO_PAD_CTRL/
Date: Mon, 14 Dec 2009 12:19:39 +0200
Message-ID: <55dd68ef700eeec904918aceb5b39e47032076e3.1260785451.git.baruch@tkos.co.il>
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

NO_PAD_CTL is not defined anywhere.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 arch/arm/plat-mxc/include/mach/iomux-mx25.h |   58 +++++++++++++-------------
 1 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/arch/arm/plat-mxc/include/mach/iomux-mx25.h b/arch/arm/plat-mxc/include/mach/iomux-mx25.h
index 810c47f..9af494f 100644
--- a/arch/arm/plat-mxc/include/mach/iomux-mx25.h
+++ b/arch/arm/plat-mxc/include/mach/iomux-mx25.h
@@ -58,19 +58,19 @@
 
 #define MX25_PAD_A18__A18		IOMUX_PAD(0x23c, 0x020, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A18__GPIO_2_4		IOMUX_PAD(0x23c, 0x020, 0x15, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A18__FEC_COL		IOMUX_PAD(0x23c, 0x020, 0x17, 0x504, 0, NO_PAD_CTL)
+#define MX25_PAD_A18__FEC_COL		IOMUX_PAD(0x23c, 0x020, 0x17, 0x504, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A19__A19		IOMUX_PAD(0x240, 0x024, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A19__FEC_RX_ER		IOMUX_PAD(0x240, 0x024, 0x17, 0x518, 0, NO_PAD_CTL)
+#define MX25_PAD_A19__FEC_RX_ER		IOMUX_PAD(0x240, 0x024, 0x17, 0x518, 0, NO_PAD_CTRL)
 #define MX25_PAD_A19__GPIO_2_5		IOMUX_PAD(0x240, 0x024, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A20__A20		IOMUX_PAD(0x244, 0x028, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A20__GPIO_2_6		IOMUX_PAD(0x244, 0x028, 0x15, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A20__FEC_RDATA2	IOMUX_PAD(0x244, 0x028, 0x17, 0x50c, 0, NO_PAD_CTL)
+#define MX25_PAD_A20__FEC_RDATA2	IOMUX_PAD(0x244, 0x028, 0x17, 0x50c, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A21__A21		IOMUX_PAD(0x248, 0x02c, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A21__GPIO_2_7		IOMUX_PAD(0x248, 0x02c, 0x15, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A21__FEC_RDATA3	IOMUX_PAD(0x248, 0x02c, 0x17, 0x510, 0, NO_PAD_CTL)
+#define MX25_PAD_A21__FEC_RDATA3	IOMUX_PAD(0x248, 0x02c, 0x17, 0x510, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A22__A22		IOMUX_PAD(0x000, 0x030, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A22__GPIO_2_8		IOMUX_PAD(0x000, 0x030, 0x15, 0, 0, NO_PAD_CTRL)
@@ -80,11 +80,11 @@
 
 #define MX25_PAD_A24__A24		IOMUX_PAD(0x250, 0x038, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A24__GPIO_2_10		IOMUX_PAD(0x250, 0x038, 0x15, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A24__FEC_RX_CLK	IOMUX_PAD(0x250, 0x038, 0x17, 0x514, 0, NO_PAD_CTL)
+#define MX25_PAD_A24__FEC_RX_CLK	IOMUX_PAD(0x250, 0x038, 0x17, 0x514, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_A25__A25		IOMUX_PAD(0x254, 0x03c, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_A25__GPIO_2_11		IOMUX_PAD(0x254, 0x03c, 0x15, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_A25__FEC_CRS		IOMUX_PAD(0x254, 0x03c, 0x17, 0x508, 0, NO_PAD_CTL)
+#define MX25_PAD_A25__FEC_CRS		IOMUX_PAD(0x254, 0x03c, 0x17, 0x508, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_EB0__EB0		IOMUX_PAD(0x258, 0x040, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_EB0__AUD4_TXD		IOMUX_PAD(0x258, 0x040, 0x14, 0x464, 0, NO_PAD_CTRL)
@@ -112,7 +112,7 @@
 #define MX25_PAD_CS5__UART5_RTS		IOMUX_PAD(0x268, 0x058, 0x13, 0x574, 0, NO_PAD_CTRL)
 #define MX25_PAD_CS5__GPIO_3_21		IOMUX_PAD(0x268, 0x058, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_NF_CE0__NF_CE0		IOMUX_PAD(0x26c, 0x05c, 0x10, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_NF_CE0__NF_CE0		IOMUX_PAD(0x26c, 0x05c, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_NF_CE0__GPIO_3_22	IOMUX_PAD(0x26c, 0x05c, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_ECB__ECB		IOMUX_PAD(0x270, 0x060, 0x10, 0, 0, NO_PAD_CTRL)
@@ -229,28 +229,28 @@
 #define MX25_PAD_LD7__GPIO_1_21		IOMUX_PAD(0x2dc, 0x0e4, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_LD8__LD8		IOMUX_PAD(0x2e0, 0x0e8, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD8__FEC_TX_ERR	IOMUX_PAD(0x2e0, 0x0e8, 0x15, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_LD8__FEC_TX_ERR	IOMUX_PAD(0x2e0, 0x0e8, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_LD9__LD9		IOMUX_PAD(0x2e4, 0x0ec, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD9__FEC_COL		IOMUX_PAD(0x2e4, 0x0ec, 0x15, 0x504, 1, NO_PAD_CTL)
+#define MX25_PAD_LD9__FEC_COL		IOMUX_PAD(0x2e4, 0x0ec, 0x15, 0x504, 1, NO_PAD_CTRL)
 
 #define MX25_PAD_LD10__LD10		IOMUX_PAD(0x2e8, 0x0f0, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD10__FEC_RX_ER	IOMUX_PAD(0x2e8, 0x0f0, 0x15, 0x518, 1, NO_PAD_CTL)
+#define MX25_PAD_LD10__FEC_RX_ER	IOMUX_PAD(0x2e8, 0x0f0, 0x15, 0x518, 1, NO_PAD_CTRL)
 
 #define MX25_PAD_LD11__LD11		IOMUX_PAD(0x2ec, 0x0f4, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD11__FEC_RDATA2	IOMUX_PAD(0x2ec, 0x0f4, 0x15, 0x50c, 1, NO_PAD_CTL)
+#define MX25_PAD_LD11__FEC_RDATA2	IOMUX_PAD(0x2ec, 0x0f4, 0x15, 0x50c, 1, NO_PAD_CTRL)
 
 #define MX25_PAD_LD12__LD12		IOMUX_PAD(0x2f0, 0x0f8, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD12__FEC_RDATA3	IOMUX_PAD(0x2f0, 0x0f8, 0x15, 0x510, 1, NO_PAD_CTL)
+#define MX25_PAD_LD12__FEC_RDATA3	IOMUX_PAD(0x2f0, 0x0f8, 0x15, 0x510, 1, NO_PAD_CTRL)
 
 #define MX25_PAD_LD13__LD13		IOMUX_PAD(0x2f4, 0x0fc, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD13__FEC_TDATA2	IOMUX_PAD(0x2f4, 0x0fc, 0x15, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_LD13__FEC_TDATA2	IOMUX_PAD(0x2f4, 0x0fc, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_LD14__LD14		IOMUX_PAD(0x2f8, 0x100, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD14__FEC_TDATA3	IOMUX_PAD(0x2f8, 0x100, 0x15, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_LD14__FEC_TDATA3	IOMUX_PAD(0x2f8, 0x100, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_LD15__LD15		IOMUX_PAD(0x2fc, 0x104, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_LD15__FEC_RX_CLK	IOMUX_PAD(0x2fc, 0x104, 0x15, 0x514, 1, NO_PAD_CTL)
+#define MX25_PAD_LD15__FEC_RX_CLK	IOMUX_PAD(0x2fc, 0x104, 0x15, 0x514, 1, NO_PAD_CTRL)
 
 #define MX25_PAD_HSYNC__HSYNC		IOMUX_PAD(0x300, 0x108, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_HSYNC__GPIO_1_22	IOMUX_PAD(0x300, 0x108, 0x15, 0, 0, NO_PAD_CTRL)
@@ -265,7 +265,7 @@
 #define MX25_PAD_OE_ACD__GPIO_1_25	IOMUX_PAD(0x30c, 0x114, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_CONTRAST__CONTRAST	IOMUX_PAD(0x310, 0x118, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_CONTRAST__FEC_CRS	IOMUX_PAD(0x310, 0x118, 0x15, 0x508, 1, NO_PAD_CTL)
+#define MX25_PAD_CONTRAST__FEC_CRS	IOMUX_PAD(0x310, 0x118, 0x15, 0x508, 1, NO_PAD_CTRL)
 
 #define MX25_PAD_PWM__PWM		IOMUX_PAD(0x314, 0x11c, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_PWM__GPIO_1_26		IOMUX_PAD(0x314, 0x11c, 0x15, 0, 0, NO_PAD_CTRL)
@@ -354,19 +354,19 @@
 #define MX25_PAD_UART2_TXD__GPIO_4_27	IOMUX_PAD(0x37c, 0x184, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_UART2_RTS__UART2_RTS	IOMUX_PAD(0x380, 0x188, 0x10, 0, 0, NO_PAD_CTRL)
-#define MX25_PAD_UART2_RTS__FEC_COL	IOMUX_PAD(0x380, 0x188, 0x12, 0x504, 2, NO_PAD_CTL)
+#define MX25_PAD_UART2_RTS__FEC_COL	IOMUX_PAD(0x380, 0x188, 0x12, 0x504, 2, NO_PAD_CTRL)
 #define MX25_PAD_UART2_RTS__GPIO_4_28	IOMUX_PAD(0x380, 0x188, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_UART2_CTS__FEC_RX_ER	IOMUX_PAD(0x384, 0x18c, 0x12, 0x518, 2, NO_PAD_CTL)
+#define MX25_PAD_UART2_CTS__FEC_RX_ER	IOMUX_PAD(0x384, 0x18c, 0x12, 0x518, 2, NO_PAD_CTRL)
 #define MX25_PAD_UART2_CTS__UART2_CTS	IOMUX_PAD(0x384, 0x18c, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_UART2_CTS__GPIO_4_29	IOMUX_PAD(0x384, 0x18c, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_SD1_CMD__SD1_CMD	IOMUX_PAD(0x388, 0x190, 0x10, 0, 0, PAD_CTL_PUS_47K_UP)
-#define MX25_PAD_SD1_CMD__FEC_RDATA2	IOMUX_PAD(0x388, 0x190, 0x12, 0x50c, 2, NO_PAD_CTL)
+#define MX25_PAD_SD1_CMD__FEC_RDATA2	IOMUX_PAD(0x388, 0x190, 0x12, 0x50c, 2, NO_PAD_CTRL)
 #define MX25_PAD_SD1_CMD__GPIO_2_23	IOMUX_PAD(0x388, 0x190, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_SD1_CLK__SD1_CLK	IOMUX_PAD(0x38c, 0x194, 0x10, 0, 0, PAD_CTL_PUS_47K_UP)
-#define MX25_PAD_SD1_CLK__FEC_RDATA3	IOMUX_PAD(0x38c, 0x194, 0x12, 0x510, 2, NO_PAD_CTL)
+#define MX25_PAD_SD1_CLK__FEC_RDATA3	IOMUX_PAD(0x38c, 0x194, 0x12, 0x510, 2, NO_PAD_CTRL)
 #define MX25_PAD_SD1_CLK__GPIO_2_24	IOMUX_PAD(0x38c, 0x194, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_SD1_DATA0__SD1_DATA0	IOMUX_PAD(0x390, 0x198, 0x10, 0, 0, PAD_CTL_PUS_47K_UP)
@@ -377,11 +377,11 @@
 #define MX25_PAD_SD1_DATA1__GPIO_2_26	IOMUX_PAD(0x394, 0x19c, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_SD1_DATA2__SD1_DATA2	IOMUX_PAD(0x398, 0x1a0, 0x10, 0, 0, PAD_CTL_PUS_47K_UP)
-#define MX25_PAD_SD1_DATA2__FEC_RX_CLK	IOMUX_PAD(0x398, 0x1a0, 0x15, 0x514, 2, NO_PAD_CTL)
+#define MX25_PAD_SD1_DATA2__FEC_RX_CLK	IOMUX_PAD(0x398, 0x1a0, 0x15, 0x514, 2, NO_PAD_CTRL)
 #define MX25_PAD_SD1_DATA2__GPIO_2_27	IOMUX_PAD(0x398, 0x1a0, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_SD1_DATA3__SD1_DATA3	IOMUX_PAD(0x39c, 0x1a4, 0x10, 0, 0, PAD_CTL_PUS_47K_UP)
-#define MX25_PAD_SD1_DATA3__FEC_CRS	IOMUX_PAD(0x39c, 0x1a4, 0x10, 0x508, 2, NO_PAD_CTL)
+#define MX25_PAD_SD1_DATA3__FEC_CRS	IOMUX_PAD(0x39c, 0x1a4, 0x10, 0x508, 2, NO_PAD_CTRL)
 #define MX25_PAD_SD1_DATA3__GPIO_2_28	IOMUX_PAD(0x39c, 0x1a4, 0x15, 0, 0, NO_PAD_CTRL)
 
 #define MX25_PAD_KPP_ROW0__KPP_ROW0	IOMUX_PAD(0x3a0, 0x1a8, 0x10, 0, 0, PAD_CTL_PKE)
@@ -410,7 +410,7 @@
 #define MX25_PAD_KPP_COL3__KPP_COL3	IOMUX_PAD(0x3bc, 0x1c4, 0x10, 0, 0, PAD_CTL_PKE | PAD_CTL_ODE)
 #define MX25_PAD_KPP_COL3__GPIO_3_4	IOMUX_PAD(0x3bc, 0x1c4, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_MDC__FEC_MDC	IOMUX_PAD(0x3c0, 0x1c8, 0x10, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_FEC_MDC__FEC_MDC	IOMUX_PAD(0x3c0, 0x1c8, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_MDC__AUD4_TXD	IOMUX_PAD(0x3c0, 0x1c8, 0x12, 0x464, 1, NO_PAD_CTRL)
 #define MX25_PAD_FEC_MDC__GPIO_3_5	IOMUX_PAD(0x3c0, 0x1c8, 0x15, 0, 0, NO_PAD_CTRL)
 
@@ -418,23 +418,23 @@
 #define MX25_PAD_FEC_MDIO__AUD4_RXD	IOMUX_PAD(0x3c4, 0x1cc, 0x12, 0x460, 1, NO_PAD_CTRL)
 #define MX25_PAD_FEC_MDIO__GPIO_3_6	IOMUX_PAD(0x3c4, 0x1cc, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TDATA0__FEC_TDATA0	IOMUX_PAD(0x3c8, 0x1d0, 0x10, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_FEC_TDATA0__FEC_TDATA0	IOMUX_PAD(0x3c8, 0x1d0, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TDATA0__GPIO_3_7	IOMUX_PAD(0x3c8, 0x1d0, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TDATA1__FEC_TDATA1	IOMUX_PAD(0x3cc, 0x1d4, 0x10, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_FEC_TDATA1__FEC_TDATA1	IOMUX_PAD(0x3cc, 0x1d4, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TDATA1__AUD4_TXFS	IOMUX_PAD(0x3cc, 0x1d4, 0x12, 0x474, 1, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TDATA1__GPIO_3_8	IOMUX_PAD(0x3cc, 0x1d4, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_TX_EN__FEC_TX_EN	IOMUX_PAD(0x3d0, 0x1d8, 0x10, 0, 0, NO_PAD_CTL)
+#define MX25_PAD_FEC_TX_EN__FEC_TX_EN	IOMUX_PAD(0x3d0, 0x1d8, 0x10, 0, 0, NO_PAD_CTRL)
 #define MX25_PAD_FEC_TX_EN__GPIO_3_9   	IOMUX_PAD(0x3d0, 0x1d8, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_RDATA0__FEC_RDATA0	IOMUX_PAD(0x3d4, 0x1dc, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTL)
+#define MX25_PAD_FEC_RDATA0__FEC_RDATA0	IOMUX_PAD(0x3d4, 0x1dc, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
 #define MX25_PAD_FEC_RDATA0__GPIO_3_10	IOMUX_PAD(0x3d4, 0x1dc, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_RDATA1__FEC_RDATA1	IOMUX_PAD(0x3d8, 0x1e0, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTL)
+#define MX25_PAD_FEC_RDATA1__FEC_RDATA1	IOMUX_PAD(0x3d8, 0x1e0, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
 #define MX25_PAD_FEC_RDATA1__GPIO_3_11	IOMUX_PAD(0x3d8, 0x1e0, 0x15, 0, 0, NO_PAD_CTRL)
 
-#define MX25_PAD_FEC_RX_DV__FEC_RX_DV	IOMUX_PAD(0x3dc, 0x1e4, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTL)
+#define MX25_PAD_FEC_RX_DV__FEC_RX_DV	IOMUX_PAD(0x3dc, 0x1e4, 0x10, 0, 0, PAD_CTL_PUS_100K_DOWN | NO_PAD_CTRL)
 #define MX25_PAD_FEC_RX_DV__CAN2_RX	IOMUX_PAD(0x3dc, 0x1e4, 0x14, 0x484, 0, PAD_CTL_PUS_22K_UP)
 #define MX25_PAD_FEC_RX_DV__GPIO_3_12	IOMUX_PAD(0x3dc, 0x1e4, 0x15, 0, 0, NO_PAD_CTRL)
 
-- 
1.6.5
