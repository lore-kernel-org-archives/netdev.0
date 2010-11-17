From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6] can: EG20T PCH: use BIT(X)
Date: Wed, 17 Nov 2010 21:22:37 +0900
Message-ID: <4CE3C90D.6010705__24152.1682161421$1289996611$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@gmail.com>,
	Samuel Ortiz <sameo@linux.inte
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:41861 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934606Ab0KQMW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 07:22:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace bit assignment value to BIT(X).
For easy to readable/identifiable, replace all bit assigned macros to BIT(X)

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |   73 +++++++++++++++++++++++----------------------
 1 files changed, 37 insertions(+), 36 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index c523e3d..238622a 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -38,50 +38,51 @@
 
 #define PCH_ENABLE		1 /* The enable flag */
 #define PCH_DISABLE		0 /* The disable flag */
-#define PCH_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
-#define PCH_CTRL_IE		0x0002 /* The IE bit of CAN control register */
-#define PCH_CTRL_IE_SIE_EIE	0x000e
-#define PCH_CTRL_CCE		0x0040
-#define PCH_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
-#define PCH_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
-#define PCH_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
+#define PCH_CTRL_INIT		BIT(0) /* The INIT bit of CANCONT register. */
+#define PCH_CTRL_IE		BIT(1) /* The IE bit of CAN control register */
+#define PCH_CTRL_IE_SIE_EIE	(BIT(3) | BIT(2) | BIT(1))
+#define PCH_CTRL_CCE		BIT(6)
+#define PCH_CTRL_OPT		BIT(7) /* The OPT bit of CANCONT register. */
+#define PCH_OPT_SILENT		BIT(3) /* The Silent bit of CANOPT reg. */
+#define PCH_OPT_LBACK		BIT(4) /* The LoopBack bit of CANOPT reg. */
+
 #define PCH_CMASK_RX_TX_SET	0x00f3
 #define PCH_CMASK_RX_TX_GET	0x0073
 #define PCH_CMASK_ALL		0xff
-#define PCH_CMASK_RDWR		0x80
-#define PCH_CMASK_ARB		0x20
-#define PCH_CMASK_CTRL		0x10
-#define PCH_CMASK_MASK		0x40
-#define PCH_CMASK_NEWDAT	0x04
-#define PCH_CMASK_CLRINTPND	0x08
-#define PCH_IF_MCONT_NEWDAT	0x8000
-#define PCH_IF_MCONT_INTPND	0x2000
-#define PCH_IF_MCONT_UMASK	0x1000
-#define PCH_IF_MCONT_TXIE	0x0800
-#define PCH_IF_MCONT_RXIE	0x0400
-#define PCH_IF_MCONT_RMTEN	0x0200
-#define PCH_IF_MCONT_TXRQXT	0x0100
-#define PCH_IF_MCONT_EOB	0x0080
-#define PCH_IF_MCONT_DLC	0x000f
-#define PCH_IF_MCONT_MSGLOST	0x4000
-#define PCH_MASK2_MDIR_MXTD	0xc000
-#define PCH_ID2_DIR		0x2000
-#define PCH_ID2_XTD		0x4000
-#define PCH_ID_MSGVAL		0x8000
-#define PCH_IF_CREQ_BUSY	0x8000
+#define PCH_CMASK_NEWDAT	BIT(2)
+#define PCH_CMASK_CLRINTPND	BIT(3)
+#define PCH_CMASK_CTRL		BIT(4)
+#define PCH_CMASK_ARB		BIT(5)
+#define PCH_CMASK_MASK		BIT(6)
+#define PCH_CMASK_RDWR		BIT(7)
+#define PCH_IF_MCONT_NEWDAT	BIT(15)
+#define PCH_IF_MCONT_MSGLOST	BIT(14)
+#define PCH_IF_MCONT_INTPND	BIT(13)
+#define PCH_IF_MCONT_UMASK	BIT(12)
+#define PCH_IF_MCONT_TXIE	BIT(11)
+#define PCH_IF_MCONT_RXIE	BIT(10)
+#define PCH_IF_MCONT_RMTEN	BIT(9)
+#define PCH_IF_MCONT_TXRQXT	BIT(8)
+#define PCH_IF_MCONT_EOB	BIT(7)
+#define PCH_IF_MCONT_DLC	(BIT(0) | BIT(1) | BIT(2) | BIT(3))
+#define PCH_MASK2_MDIR_MXTD	(BIT(14) | BIT(15))
+#define PCH_ID2_DIR		BIT(13)
+#define PCH_ID2_XTD		BIT(14)
+#define PCH_ID_MSGVAL		BIT(15)
+#define PCH_IF_CREQ_BUSY	BIT(15)
 
 #define PCH_STATUS_INT		0x8000
 #define PCH_REC			0x00007f00
 #define PCH_TEC			0x000000ff
 
-#define PCH_RX_OK		0x00000010
-#define PCH_TX_OK		0x00000008
-#define PCH_BUS_OFF		0x00000080
-#define PCH_EWARN		0x00000040
-#define PCH_EPASSIV		0x00000020
-#define PCH_LEC0		0x00000001
-#define PCH_LEC1		0x00000002
-#define PCH_LEC2		0x00000004
+#define PCH_TX_OK		BIT(3)
+#define PCH_RX_OK		BIT(4)
+#define PCH_EPASSIV		BIT(5)
+#define PCH_EWARN		BIT(6)
+#define PCH_BUS_OFF		BIT(7)
+#define PCH_LEC0		BIT(0)
+#define PCH_LEC1		BIT(1)
+#define PCH_LEC2		BIT(2)
 #define PCH_LEC_ALL		(PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
 #define PCH_STUF_ERR		PCH_LEC0
 #define PCH_FORM_ERR		PCH_LEC1
-- 
1.6.0.6

