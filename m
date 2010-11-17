From: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
Subject: [PATCH net-next-2.6 ] can: EG20T PCH: add  prefix to macro
Date: Wed, 17 Nov 2010 14:13:49 +0900
Message-ID: <4CE3648D.2070102__30869.0051701435$1289970904$gmane$org@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, margie.foster@intel.com
To: Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Christian Pellegrin <chripell@fsfe.org>,
	Barry Song <21cnbao@g
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:22967 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751109Ab0KQFOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 00:14:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For easy to readable/identifiable, add prefix "PCH_" to all of #define macros.

Signed-off-by: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |  392 ++++++++++++++++++++++-----------------------
 1 files changed, 190 insertions(+), 202 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 6727182..b4bb775 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -32,49 +32,48 @@
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
-#define MAX_MSG_OBJ		32
-#define MSG_OBJ_RX		0 /* The receive message object flag. */
-#define MSG_OBJ_TX		1 /* The transmit message object flag. */
-
-#define ENABLE			1 /* The enable flag */
-#define DISABLE			0 /* The disable flag */
-#define CAN_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
-#define CAN_CTRL_IE		0x0002 /* The IE bit of CAN control register */
-#define CAN_CTRL_IE_SIE_EIE	0x000e
-#define CAN_CTRL_CCE		0x0040
-#define CAN_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
-#define CAN_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
-#define CAN_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
-#define CAN_CMASK_RX_TX_SET	0x00f3
-#define CAN_CMASK_RX_TX_GET	0x0073
-#define CAN_CMASK_ALL		0xff
-#define CAN_CMASK_RDWR		0x80
-#define CAN_CMASK_ARB		0x20
-#define CAN_CMASK_CTRL		0x10
-#define CAN_CMASK_MASK		0x40
-#define CAN_CMASK_NEWDAT	0x04
-#define CAN_CMASK_CLRINTPND	0x08
-
-#define CAN_IF_MCONT_NEWDAT	0x8000
-#define CAN_IF_MCONT_INTPND	0x2000
-#define CAN_IF_MCONT_UMASK	0x1000
-#define CAN_IF_MCONT_TXIE	0x0800
-#define CAN_IF_MCONT_RXIE	0x0400
-#define CAN_IF_MCONT_RMTEN	0x0200
-#define CAN_IF_MCONT_TXRQXT	0x0100
-#define CAN_IF_MCONT_EOB	0x0080
-#define CAN_IF_MCONT_DLC	0x000f
-#define CAN_IF_MCONT_MSGLOST	0x4000
-#define CAN_MASK2_MDIR_MXTD	0xc000
-#define CAN_ID2_DIR		0x2000
-#define CAN_ID_MSGVAL		0x8000
-
-#define CAN_STATUS_INT		0x8000
-#define CAN_IF_CREQ_BUSY	0x8000
-#define CAN_ID2_XTD		0x4000
-
-#define CAN_REC			0x00007f00
-#define CAN_TEC			0x000000ff
+#define PCH_MAX_MSG_OBJ		32
+#define PCH_MSG_OBJ_RX		0 /* The receive message object flag. */
+#define PCH_MSG_OBJ_TX		1 /* The transmit message object flag. */
+
+#define PCH_ENABLE			1 /* The enable flag */
+#define PCH_DISABLE			0 /* The disable flag */
+#define PCH_CTRL_INIT		0x0001 /* The INIT bit of CANCONT register. */
+#define PCH_CTRL_IE		0x0002 /* The IE bit of CAN control register */
+#define PCH_CTRL_IE_SIE_EIE	0x000e
+#define PCH_CTRL_CCE		0x0040
+#define PCH_CTRL_OPT		0x0080 /* The OPT bit of CANCONT register. */
+#define PCH_OPT_SILENT		0x0008 /* The Silent bit of CANOPT reg. */
+#define PCH_OPT_LBACK		0x0010 /* The LoopBack bit of CANOPT reg. */
+#define PCH_CMASK_RX_TX_SET	0x00f3
+#define PCH_CMASK_RX_TX_GET	0x0073
+#define PCH_CMASK_ALL		0xff
+#define PCH_CMASK_RDWR		0x80
+#define PCH_CMASK_ARB		0x20
+#define PCH_CMASK_CTRL		0x10
+#define PCH_CMASK_MASK		0x40
+#define PCH_CMASK_NEWDAT	0x04
+#define PCH_CMASK_CLRINTPND	0x08
+#define PCH_IF_MCONT_NEWDAT	0x8000
+#define PCH_IF_MCONT_INTPND	0x2000
+#define PCH_IF_MCONT_UMASK	0x1000
+#define PCH_IF_MCONT_TXIE	0x0800
+#define PCH_IF_MCONT_RXIE	0x0400
+#define PCH_IF_MCONT_RMTEN	0x0200
+#define PCH_IF_MCONT_TXRQXT	0x0100
+#define PCH_IF_MCONT_EOB	0x0080
+#define PCH_IF_MCONT_DLC	0x000f
+#define PCH_IF_MCONT_MSGLOST	0x4000
+#define PCH_MASK2_MDIR_MXTD	0xc000
+#define PCH_ID2_DIR		0x2000
+#define PCH_ID2_XTD		0x4000
+#define PCH_ID_MSGVAL		0x8000
+#define PCH_IF_CREQ_BUSY	0x8000
+
+#define PCH_STATUS_INT		0x8000
+#define PCH_REC			0x00007f00
+#define PCH_TEC			0x000000ff
+
 
 #define PCH_RX_OK		0x00000010
 #define PCH_TX_OK		0x00000008
@@ -93,26 +92,15 @@
 #define PCH_CRC_ERR		(PCH_LEC1 | PCH_LEC2)
 
 /* bit position of certain controller bits. */
-#define BIT_BITT_BRP		0
-#define BIT_BITT_SJW		6
-#define BIT_BITT_TSEG1		8
-#define BIT_BITT_TSEG2		12
-#define BIT_IF1_MCONT_RXIE	10
-#define BIT_IF2_MCONT_TXIE	11
-#define BIT_BRPE_BRPE		6
-#define BIT_ES_TXERRCNT		0
-#define BIT_ES_RXERRCNT		8
-#define MSK_BITT_BRP		0x3f
-#define MSK_BITT_SJW		0xc0
-#define MSK_BITT_TSEG1		0xf00
-#define MSK_BITT_TSEG2		0x7000
-#define MSK_BRPE_BRPE		0x3c0
-#define MSK_BRPE_GET		0x0f
-#define MSK_CTRL_IE_SIE_EIE	0x07
-#define MSK_MCONT_TXIE		0x08
-#define MSK_MCONT_RXIE		0x10
-#define PCH_CAN_NO_TX_BUFF	1
-#define COUNTER_LIMIT		10
+#define PCH_BIT_BRP		0
+#define PCH_BIT_SJW		6
+#define PCH_BIT_TSEG1		8
+#define PCH_BIT_TSEG2		12
+#define PCH_BIT_BRPE_BRPE		6
+#define PCH_MSK_BITT_BRP		0x3f
+#define PCH_MSK_BRPE_BRPE		0x3c0
+#define PCH_MSK_CTRL_IE_SIE_EIE	0x07
+#define PCH_COUNTER_LIMIT		10
 
 #define PCH_CAN_CLK		50000000	/* 50MHz */
 
@@ -181,14 +169,14 @@ struct pch_can_priv {
 	struct can_priv can;
 	unsigned int can_num;
 	struct pci_dev *dev;
-	unsigned int tx_enable[MAX_MSG_OBJ];
-	unsigned int rx_enable[MAX_MSG_OBJ];
-	unsigned int rx_link[MAX_MSG_OBJ];
+	unsigned int tx_enable[PCH_MAX_MSG_OBJ];
+	unsigned int rx_enable[PCH_MAX_MSG_OBJ];
+	unsigned int rx_link[PCH_MAX_MSG_OBJ];
 	unsigned int int_enables;
 	unsigned int int_stat;
 	struct net_device *ndev;
 	spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock*/
-	unsigned int msg_obj[MAX_MSG_OBJ];
+	unsigned int msg_obj[PCH_MAX_MSG_OBJ];
 	struct pch_can_regs __iomem *regs;
 	struct napi_struct napi;
 	unsigned int tx_obj;	/* Point next Tx Obj index */
@@ -228,11 +216,11 @@ static void pch_can_set_run_mode(struct pch_can_priv *priv,
 {
 	switch (mode) {
 	case PCH_CAN_RUN:
-		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_INIT);
+		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_INIT);
 		break;
 
 	case PCH_CAN_STOP:
-		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_INIT);
+		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_INIT);
 		break;
 
 	default:
@@ -246,30 +234,30 @@ static void pch_can_set_optmode(struct pch_can_priv *priv)
 	u32 reg_val = ioread32(&priv->regs->opt);
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY)
-		reg_val |= CAN_OPT_SILENT;
+		reg_val |= PCH_OPT_SILENT;
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
-		reg_val |= CAN_OPT_LBACK;
+		reg_val |= PCH_OPT_LBACK;
 
-	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_OPT);
+	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_OPT);
 	iowrite32(reg_val, &priv->regs->opt);
 }
 
 static void pch_can_set_int_custom(struct pch_can_priv *priv)
 {
 	/* Clearing the IE, SIE and EIE bits of Can control register. */
-	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
+	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
 
 	/* Appropriately setting them. */
 	pch_can_bit_set(&priv->regs->cont,
-			((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
+			((priv->int_enables & PCH_MSK_CTRL_IE_SIE_EIE) << 1));
 }
 
 /* This function retrieves interrupt enabled for the CAN device. */
 static void pch_can_get_int_enables(struct pch_can_priv *priv, u32 *enables)
 {
 	/* Obtaining the status of IE, SIE and EIE interrupt bits. */
-	*enables = ((ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> 1);
+	*enables = ((ioread32(&priv->regs->cont) & PCH_CTRL_IE_SIE_EIE) >> 1);
 }
 
 static void pch_can_set_int_enables(struct pch_can_priv *priv,
@@ -277,19 +265,19 @@ static void pch_can_set_int_enables(struct pch_can_priv *priv,
 {
 	switch (interrupt_no) {
 	case PCH_CAN_ENABLE:
-		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE);
+		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE);
 		break;
 
 	case PCH_CAN_DISABLE:
-		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE);
+		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE);
 		break;
 
 	case PCH_CAN_ALL:
-		pch_can_bit_set(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
+		pch_can_bit_set(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
 		break;
 
 	case PCH_CAN_NONE:
-		pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
+		pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_IE_SIE_EIE);
 		break;
 
 	default:
@@ -300,12 +288,12 @@ static void pch_can_set_int_enables(struct pch_can_priv *priv,
 
 static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
 {
-	u32 counter = COUNTER_LIMIT;
+	u32 counter = PCH_COUNTER_LIMIT;
 	u32 ifx_creq;
 
 	iowrite32(num, creq_addr);
 	while (counter) {
-		ifx_creq = ioread32(creq_addr) & CAN_IF_CREQ_BUSY;
+		ifx_creq = ioread32(creq_addr) & PCH_IF_CREQ_BUSY;
 		if (!ifx_creq)
 			break;
 		counter--;
@@ -322,22 +310,22 @@ static void pch_can_set_rx_enable(struct pch_can_priv *priv, u32 buff_num,
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	/* Reading the receive buffer data from RAM to Interface1 registers */
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
 	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
 
 	/* Setting the IF1MASK1 register to access MsgVal and RxIE bits */
-	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
+	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
 		  &priv->regs->if1_cmask);
 
-	if (set == ENABLE) {
+	if (set == PCH_ENABLE) {
 		/* Setting the MsgVal and RxIE bits */
-		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
-		pch_can_bit_set(&priv->regs->if1_id2, CAN_ID_MSGVAL);
+		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
+		pch_can_bit_set(&priv->regs->if1_id2, PCH_ID_MSGVAL);
 
-	} else if (set == DISABLE) {
+	} else if (set == PCH_DISABLE) {
 		/* Resetting the MsgVal and RxIE bits */
-		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
-		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID_MSGVAL);
+		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_RXIE);
+		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID_MSGVAL);
 	}
 
 	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
@@ -350,8 +338,8 @@ static void pch_can_rx_enable_all(struct pch_can_priv *priv)
 
 	/* Traversing to obtain the object configured as receivers. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_RX)
-			pch_can_set_rx_enable(priv, i + 1, ENABLE);
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX)
+			pch_can_set_rx_enable(priv, i + 1, PCH_ENABLE);
 	}
 }
 
@@ -361,8 +349,8 @@ static void pch_can_rx_disable_all(struct pch_can_priv *priv)
 
 	/* Traversing to obtain the object configured as receivers. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_RX)
-			pch_can_set_rx_enable(priv, i + 1, DISABLE);
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX)
+			pch_can_set_rx_enable(priv, i + 1, PCH_DISABLE);
 	}
 }
 
@@ -373,22 +361,22 @@ static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_num,
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 	/* Reading the Msg buffer from Message RAM to Interface2 registers. */
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
 	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
 
 	/* Setting the IF2CMASK register for accessing the
 		MsgVal and TxIE bits */
-	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
+	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_ARB | PCH_CMASK_CTRL,
 		 &priv->regs->if2_cmask);
 
-	if (set == ENABLE) {
+	if (set == PCH_ENABLE) {
 		/* Setting the MsgVal and TxIE bits */
-		pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
-		pch_can_bit_set(&priv->regs->if2_id2, CAN_ID_MSGVAL);
-	} else if (set == DISABLE) {
+		pch_can_bit_set(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
+		pch_can_bit_set(&priv->regs->if2_id2, PCH_ID_MSGVAL);
+	} else if (set == PCH_DISABLE) {
 		/* Resetting the MsgVal and TxIE bits. */
-		pch_can_bit_clear(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
-		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID_MSGVAL);
+		pch_can_bit_clear(&priv->regs->if2_mcont, PCH_IF_MCONT_TXIE);
+		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID_MSGVAL);
 	}
 
 	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
@@ -401,8 +389,8 @@ static void pch_can_tx_enable_all(struct pch_can_priv *priv)
 
 	/* Traversing to obtain the object configured as transmit object. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_TX)
-			pch_can_set_tx_enable(priv, i + 1, ENABLE);
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
+			pch_can_set_tx_enable(priv, i + 1, PCH_ENABLE);
 	}
 }
 
@@ -412,8 +400,8 @@ static void pch_can_tx_disable_all(struct pch_can_priv *priv)
 
 	/* Traversing to obtain the object configured as transmit object. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_TX)
-			pch_can_set_tx_enable(priv, i + 1, DISABLE);
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
+			pch_can_set_tx_enable(priv, i + 1, PCH_DISABLE);
 	}
 }
 
@@ -423,15 +411,15 @@ static void pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_num,
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
 	pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
 
-	if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
+	if (((ioread32(&priv->regs->if1_id2)) & PCH_ID_MSGVAL) &&
 			((ioread32(&priv->regs->if1_mcont)) &
-			CAN_IF_MCONT_RXIE))
-		*enable = ENABLE;
+			PCH_IF_MCONT_RXIE))
+		*enable = PCH_ENABLE;
 	else
-		*enable = DISABLE;
+		*enable = PCH_DISABLE;
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
 
@@ -441,15 +429,15 @@ static void pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_num,
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
 	pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
 
-	if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
+	if (((ioread32(&priv->regs->if2_id2)) & PCH_ID_MSGVAL) &&
 			((ioread32(&priv->regs->if2_mcont)) &
-			CAN_IF_MCONT_TXIE)) {
-		*enable = ENABLE;
+			PCH_IF_MCONT_TXIE)) {
+		*enable = PCH_ENABLE;
 	} else {
-		*enable = DISABLE;
+		*enable = PCH_DISABLE;
 	}
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
@@ -465,13 +453,13 @@ static void pch_can_set_rx_buffer_link(struct pch_can_priv *priv,
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
 	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
-	iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL, &priv->regs->if1_cmask);
-	if (set == ENABLE)
-		pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
+	iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL, &priv->regs->if1_cmask);
+	if (set == PCH_ENABLE)
+		pch_can_bit_clear(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
 	else
-		pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_EOB);
+		pch_can_bit_set(&priv->regs->if1_mcont, PCH_IF_MCONT_EOB);
 
 	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
@@ -483,13 +471,13 @@ static void pch_can_get_rx_buffer_link(struct pch_can_priv *priv,
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
 	pch_can_check_if_busy(&priv->regs->if1_creq, buffer_num);
 
-	if (ioread32(&priv->regs->if1_mcont) & CAN_IF_MCONT_EOB)
-		*link = DISABLE;
+	if (ioread32(&priv->regs->if1_mcont) & PCH_IF_MCONT_EOB)
+		*link = PCH_DISABLE;
 	else
-		*link = ENABLE;
+		*link = PCH_ENABLE;
 	spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 }
 
@@ -498,7 +486,7 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 	int i;
 
 	for (i = 0; i < PCH_RX_OBJ_NUM; i++) {
-		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
+		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
 		iowrite32(0xffff, &priv->regs->if1_mask1);
 		iowrite32(0xffff, &priv->regs->if1_mask2);
 		iowrite32(0x0, &priv->regs->if1_id1);
@@ -508,14 +496,14 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(0x0, &priv->regs->if1_dataa2);
 		iowrite32(0x0, &priv->regs->if1_datab1);
 		iowrite32(0x0, &priv->regs->if1_datab2);
-		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
-			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
+			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->if1_cmask);
 		pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
 	}
 
 	for (i = i;  i < PCH_OBJ_NUM; i++) {
-		iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
+		iowrite32(PCH_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
 		iowrite32(0xffff, &priv->regs->if2_mask1);
 		iowrite32(0xffff, &priv->regs->if2_mask2);
 		iowrite32(0x0, &priv->regs->if2_id1);
@@ -525,8 +513,8 @@ static void pch_can_clear_buffers(struct pch_can_priv *priv)
 		iowrite32(0x0, &priv->regs->if2_dataa2);
 		iowrite32(0x0, &priv->regs->if2_datab1);
 		iowrite32(0x0, &priv->regs->if2_datab2);
-		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
-			  CAN_CMASK_ARB | CAN_CMASK_CTRL,
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
+			  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 			  &priv->regs->if2_cmask);
 		pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
 	}
@@ -540,8 +528,8 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_RX) {
-			iowrite32(CAN_CMASK_RX_TX_GET,
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
+			iowrite32(PCH_CMASK_RX_TX_GET,
 				&priv->regs->if1_cmask);
 			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
 
@@ -549,48 +537,48 @@ static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
 			iowrite32(0x0, &priv->regs->if1_id2);
 
 			pch_can_bit_set(&priv->regs->if1_mcont,
-					CAN_IF_MCONT_UMASK);
+					PCH_IF_MCONT_UMASK);
 
 			/* Set FIFO mode set to 0 except last Rx Obj*/
 			pch_can_bit_clear(&priv->regs->if1_mcont,
-					  CAN_IF_MCONT_EOB);
+					  PCH_IF_MCONT_EOB);
 			/* In case FIFO mode, Last EoB of Rx Obj must be 1 */
 			if (i == (PCH_RX_OBJ_NUM - 1))
 				pch_can_bit_set(&priv->regs->if1_mcont,
-						  CAN_IF_MCONT_EOB);
+						  PCH_IF_MCONT_EOB);
 
 			iowrite32(0, &priv->regs->if1_mask1);
 			pch_can_bit_clear(&priv->regs->if1_mask2,
-					  0x1fff | CAN_MASK2_MDIR_MXTD);
+					  0x1fff | PCH_MASK2_MDIR_MXTD);
 
 			/* Setting CMASK for writing */
-			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
-				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
+			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
+				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 				  &priv->regs->if1_cmask);
 
 			pch_can_check_if_busy(&priv->regs->if1_creq, i+1);
-		} else if (priv->msg_obj[i] == MSG_OBJ_TX) {
-			iowrite32(CAN_CMASK_RX_TX_GET,
+		} else if (priv->msg_obj[i] == PCH_MSG_OBJ_TX) {
+			iowrite32(PCH_CMASK_RX_TX_GET,
 				&priv->regs->if2_cmask);
 			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
 
 			/* Resetting DIR bit for reception */
 			iowrite32(0x0, &priv->regs->if2_id1);
 			iowrite32(0x0, &priv->regs->if2_id2);
-			pch_can_bit_set(&priv->regs->if2_id2, CAN_ID2_DIR);
+			pch_can_bit_set(&priv->regs->if2_id2, PCH_ID2_DIR);
 
 			/* Setting EOB bit for transmitter */
-			iowrite32(CAN_IF_MCONT_EOB, &priv->regs->if2_mcont);
+			iowrite32(PCH_IF_MCONT_EOB, &priv->regs->if2_mcont);
 
 			pch_can_bit_set(&priv->regs->if2_mcont,
-					CAN_IF_MCONT_UMASK);
+					PCH_IF_MCONT_UMASK);
 
 			iowrite32(0, &priv->regs->if2_mask1);
 			pch_can_bit_clear(&priv->regs->if2_mask2, 0x1fff);
 
 			/* Setting CMASK for writing */
-			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
-				  CAN_CMASK_ARB | CAN_CMASK_CTRL,
+			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_MASK |
+				  PCH_CMASK_ARB | PCH_CMASK_CTRL,
 				  &priv->regs->if2_cmask);
 
 			pch_can_check_if_busy(&priv->regs->if2_creq, i+1);
@@ -632,39 +620,39 @@ static void pch_can_release(struct pch_can_priv *priv)
 /* This function clears interrupt(s) from the CAN device. */
 static void pch_can_int_clr(struct pch_can_priv *priv, u32 mask)
 {
-	if (mask == CAN_STATUS_INT) {
+	if (mask == PCH_STATUS_INT) {
 		ioread32(&priv->regs->stat);
 		return;
 	}
 
 	/* Clear interrupt for transmit object */
-	if (priv->msg_obj[mask - 1] == MSG_OBJ_TX) {
+	if (priv->msg_obj[mask - 1] == PCH_MSG_OBJ_TX) {
 		/* Setting CMASK for clearing interrupts for
 					 frame transmission. */
-		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
 			  &priv->regs->if2_cmask);
 
 		/* Resetting the ID registers. */
 		pch_can_bit_set(&priv->regs->if2_id2,
-			       CAN_ID2_DIR | (0x7ff << 2));
+			       PCH_ID2_DIR | (0x7ff << 2));
 		iowrite32(0x0, &priv->regs->if2_id1);
 
 		/* Claring NewDat, TxRqst & IntPnd */
 		pch_can_bit_clear(&priv->regs->if2_mcont,
-				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
-				  CAN_IF_MCONT_TXRQXT);
+				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
+				  PCH_IF_MCONT_TXRQXT);
 		pch_can_check_if_busy(&priv->regs->if2_creq, mask);
-	} else if (priv->msg_obj[mask - 1] == MSG_OBJ_RX) {
+	} else if (priv->msg_obj[mask - 1] == PCH_MSG_OBJ_RX) {
 		/* Setting CMASK for clearing the reception interrupts. */
-		iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL | CAN_CMASK_ARB,
+		iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL | PCH_CMASK_ARB,
 			  &priv->regs->if1_cmask);
 
 		/* Clearing the Dir bit. */
-		pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
+		pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
 
 		/* Clearing NewDat & IntPnd */
 		pch_can_bit_clear(&priv->regs->if1_mcont,
-				  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND);
+				  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND);
 
 		pch_can_check_if_busy(&priv->regs->if1_creq, mask);
 	}
@@ -712,9 +700,9 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		priv->can.can_stats.error_warning++;
 		cf->can_id |= CAN_ERR_CRTL;
 		errc = ioread32(&priv->regs->errc);
-		if (((errc & CAN_REC) >> 8) > 96)
+		if (((errc & PCH_REC) >> 8) > 96)
 			cf->data[1] |= CAN_ERR_CRTL_RX_WARNING;
-		if ((errc & CAN_TEC) > 96)
+		if ((errc & PCH_TEC) > 96)
 			cf->data[1] |= CAN_ERR_CRTL_TX_WARNING;
 		dev_warn(&ndev->dev,
 			"%s -> Error Counter is more than 96.\n", __func__);
@@ -725,9 +713,9 @@ static void pch_can_error(struct net_device *ndev, u32 status)
 		state = CAN_STATE_ERROR_PASSIVE;
 		cf->can_id |= CAN_ERR_CRTL;
 		errc = ioread32(&priv->regs->errc);
-		if (((errc & CAN_REC) >> 8) > 127)
+		if (((errc & PCH_REC) >> 8) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
-		if ((errc & CAN_TEC) > 127)
+		if ((errc & PCH_TEC) > 127)
 			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
 		dev_err(&ndev->dev,
 			"%s -> CAN controller is ERROR PASSIVE .\n", __func__);
@@ -795,20 +783,20 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 	struct net_device_stats *stats = &(priv->ndev->stats);
 
 	/* Reading the messsage object from the Message RAM */
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
 	pch_can_check_if_busy(&priv->regs->if1_creq, int_stat);
 
 	/* Reading the MCONT register. */
 	reg = ioread32(&priv->regs->if1_mcont);
 	reg &= 0xffff;
 
-	for (k = int_stat; !(reg & CAN_IF_MCONT_EOB); k++) {
+	for (k = int_stat; !(reg & PCH_IF_MCONT_EOB); k++) {
 		/* If MsgLost bit set. */
-		if (reg & CAN_IF_MCONT_MSGLOST) {
+		if (reg & PCH_IF_MCONT_MSGLOST) {
 			dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
 			pch_can_bit_clear(&priv->regs->if1_mcont,
-					  CAN_IF_MCONT_MSGLOST);
-			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL,
+					  PCH_IF_MCONT_MSGLOST);
+			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL,
 				  &priv->regs->if1_cmask);
 			pch_can_check_if_busy(&priv->regs->if1_creq, k);
 
@@ -828,7 +816,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 			rcv_pkts++;
 			goto RX_NEXT;
 		}
-		if (!(reg & CAN_IF_MCONT_NEWDAT))
+		if (!(reg & PCH_IF_MCONT_NEWDAT))
 			goto RX_NEXT;
 
 		skb = alloc_can_skb(priv->ndev, &cf);
@@ -836,7 +824,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 			return -ENOMEM;
 
 		/* Get Received data */
-		ide = ((ioread32(&priv->regs->if1_id2)) & CAN_ID2_XTD) >> 14;
+		ide = ((ioread32(&priv->regs->if1_id2)) & PCH_ID2_XTD) >> 14;
 		if (ide) {
 			id = (ioread32(&priv->regs->if1_id1) & 0xffff);
 			id |= (((ioread32(&priv->regs->if1_id2)) &
@@ -848,7 +836,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 			cf->can_id = (id & CAN_SFF_MASK);
 		}
 
-		rtr = (ioread32(&priv->regs->if1_id2) &  CAN_ID2_DIR);
+		rtr = (ioread32(&priv->regs->if1_id2) &  PCH_ID2_DIR);
 		if (rtr) {
 			cf->can_dlc = 0;
 			cf->can_id |= CAN_RTR_FLAG;
@@ -871,15 +859,15 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 		stats->rx_bytes += cf->can_dlc;
 
 		if (k < PCH_FIFO_THRESH) {
-			iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL |
-				  CAN_CMASK_ARB, &priv->regs->if1_cmask);
+			iowrite32(PCH_CMASK_RDWR | PCH_CMASK_CTRL |
+				  PCH_CMASK_ARB, &priv->regs->if1_cmask);
 
 			/* Clearing the Dir bit. */
-			pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID2_DIR);
+			pch_can_bit_clear(&priv->regs->if1_id2, PCH_ID2_DIR);
 
 			/* Clearing NewDat & IntPnd */
 			pch_can_bit_clear(&priv->regs->if1_mcont,
-					  CAN_IF_MCONT_INTPND);
+					  PCH_IF_MCONT_INTPND);
 			pch_can_check_if_busy(&priv->regs->if1_creq, k);
 		} else if (k > PCH_FIFO_THRESH) {
 			pch_can_int_clr(priv, k);
@@ -890,7 +878,7 @@ static int pch_can_rx_normal(struct net_device *ndev, u32 int_stat)
 		}
 RX_NEXT:
 		/* Reading the messsage object from the Message RAM */
-		iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
+		iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
 		pch_can_check_if_busy(&priv->regs->if1_creq, k + 1);
 		reg = ioread32(&priv->regs->if1_mcont);
 	}
@@ -913,7 +901,7 @@ static int pch_can_rx_poll(struct napi_struct *napi, int quota)
 		return 0;
 
 INT_STAT:
-	if (int_stat == CAN_STATUS_INT) {
+	if (int_stat == PCH_STATUS_INT) {
 		reg_stat = ioread32(&priv->regs->stat);
 		if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
 			if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL)
@@ -922,7 +910,7 @@ INT_STAT:
 
 		if (reg_stat & PCH_TX_OK) {
 			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-			iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
+			iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
 			pch_can_check_if_busy(&priv->regs->if2_creq,
 					       ioread32(&priv->regs->intr));
 			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
@@ -933,7 +921,7 @@ INT_STAT:
 			pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
 
 		int_stat = pch_can_int_pending(priv);
-		if (int_stat == CAN_STATUS_INT)
+		if (int_stat == PCH_STATUS_INT)
 			goto INT_STAT;
 	}
 
@@ -945,14 +933,14 @@ MSG_OBJ:
 		if (rcv_pkts < 0)
 			return 0;
 	} else if ((int_stat > PCH_RX_OBJ_NUM) && (int_stat <= PCH_OBJ_NUM)) {
-		if (priv->msg_obj[int_stat - 1] == MSG_OBJ_TX) {
+		if (priv->msg_obj[int_stat - 1] == PCH_MSG_OBJ_TX) {
 			/* Handle transmission interrupt */
 			can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
 			spin_lock_irqsave(&priv->msgif_reg_lock, flags);
-			iowrite32(CAN_CMASK_RX_TX_GET | CAN_CMASK_CLRINTPND,
+			iowrite32(PCH_CMASK_RX_TX_GET | PCH_CMASK_CLRINTPND,
 				  &priv->regs->if2_cmask);
 			dlc = ioread32(&priv->regs->if2_mcont) &
-				       CAN_IF_MCONT_DLC;
+				       PCH_IF_MCONT_DLC;
 			pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
 			spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
 			if (dlc > 8)
@@ -963,7 +951,7 @@ MSG_OBJ:
 	}
 
 	int_stat = pch_can_int_pending(priv);
-	if (int_stat == CAN_STATUS_INT)
+	if (int_stat == PCH_STATUS_INT)
 		goto INT_STAT;
 	else if (int_stat >= 1 && int_stat <= 32)
 		goto MSG_OBJ;
@@ -983,17 +971,17 @@ static int pch_set_bittiming(struct net_device *ndev)
 	u32 brp;
 
 	/* Setting the CCE bit for accessing the Can Timing register. */
-	pch_can_bit_set(&priv->regs->cont, CAN_CTRL_CCE);
+	pch_can_bit_set(&priv->regs->cont, PCH_CTRL_CCE);
 
 	brp = (bt->tq) / (1000000000/PCH_CAN_CLK) - 1;
-	canbit = brp & MSK_BITT_BRP;
-	canbit |= (bt->sjw - 1) << BIT_BITT_SJW;
-	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << BIT_BITT_TSEG1;
-	canbit |= (bt->phase_seg2 - 1) << BIT_BITT_TSEG2;
-	bepe = (brp & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE;
+	canbit = brp & PCH_MSK_BITT_BRP;
+	canbit |= (bt->sjw - 1) << PCH_BIT_SJW;
+	canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << PCH_BIT_TSEG1;
+	canbit |= (bt->phase_seg2 - 1) << PCH_BIT_TSEG2;
+	bepe = (brp & PCH_MSK_BRPE_BRPE) >> PCH_BIT_BRPE_BRPE;
 	iowrite32(canbit, &priv->regs->bitt);
 	iowrite32(bepe, &priv->regs->brpe);
-	pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_CCE);
+	pch_can_bit_clear(&priv->regs->cont, PCH_CTRL_CCE);
 
 	return 0;
 }
@@ -1137,19 +1125,19 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 	spin_lock_irqsave(&priv->msgif_reg_lock, flags);
 
 	/* Reading the Msg Obj from the Msg RAM to the Interface register. */
-	iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
+	iowrite32(PCH_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
 	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
 
 	/* Setting the CMASK register. */
-	pch_can_bit_set(&priv->regs->if2_cmask, CAN_CMASK_ALL);
+	pch_can_bit_set(&priv->regs->if2_cmask, PCH_CMASK_ALL);
 
 	/* If ID extended is set. */
 	pch_can_bit_clear(&priv->regs->if2_id1, 0xffff);
-	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | CAN_ID2_XTD);
+	pch_can_bit_clear(&priv->regs->if2_id2, 0x1fff | PCH_ID2_XTD);
 	if (cf->can_id & CAN_EFF_FLAG) {
 		pch_can_bit_set(&priv->regs->if2_id1, cf->can_id & 0xffff);
 		pch_can_bit_set(&priv->regs->if2_id2,
-				((cf->can_id >> 16) & 0x1fff) | CAN_ID2_XTD);
+				((cf->can_id >> 16) & 0x1fff) | PCH_ID2_XTD);
 	} else {
 		pch_can_bit_set(&priv->regs->if2_id1, 0);
 		pch_can_bit_set(&priv->regs->if2_id2,
@@ -1158,7 +1146,7 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	/* If remote frame has to be transmitted.. */
 	if (cf->can_id & CAN_RTR_FLAG)
-		pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID2_DIR);
+		pch_can_bit_clear(&priv->regs->if2_id2, PCH_ID2_DIR);
 
 	for (i = 0, j = 0; i < cf->can_dlc; j++) {
 		iowrite32(le32_to_cpu(cf->data[i++]),
@@ -1177,12 +1165,12 @@ static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	/* Clearing IntPend, NewDat & TxRqst */
 	pch_can_bit_clear(&priv->regs->if2_mcont,
-			  CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_INTPND |
-			  CAN_IF_MCONT_TXRQXT);
+			  PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_INTPND |
+			  PCH_IF_MCONT_TXRQXT);
 
 	/* Setting NewDat, TxRqst bits */
 	pch_can_bit_set(&priv->regs->if2_mcont,
-			CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT);
+			PCH_IF_MCONT_NEWDAT | PCH_IF_MCONT_TXRQXT);
 
 	pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
 
@@ -1245,7 +1233,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	/* Save Tx buffer enable state */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_TX)
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX)
 			pch_can_get_tx_enable(priv, i + 1,
 					      &(priv->tx_enable[i]));
 	}
@@ -1255,7 +1243,7 @@ static int pch_can_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	/* Save Rx buffer enable state */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_RX) {
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
 			pch_can_get_rx_enable(priv, i + 1,
 						&(priv->rx_enable[i]));
 			pch_can_get_rx_buffer_link(priv, i + 1,
@@ -1313,7 +1301,7 @@ static int pch_can_resume(struct pci_dev *pdev)
 
 	/* Enabling the transmit buffer. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_TX) {
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_TX) {
 			pch_can_set_tx_enable(priv, i + 1,
 					      priv->tx_enable[i]);
 		}
@@ -1321,7 +1309,7 @@ static int pch_can_resume(struct pci_dev *pdev)
 
 	/* Configuring the receive buffer and enabling them. */
 	for (i = 0; i < PCH_OBJ_NUM; i++) {
-		if (priv->msg_obj[i] == MSG_OBJ_RX) {
+		if (priv->msg_obj[i] == PCH_MSG_OBJ_RX) {
 			/* Restore buffer link */
 			pch_can_set_rx_buffer_link(priv, i + 1,
 						   priv->rx_link[i]);
@@ -1349,8 +1337,8 @@ static int pch_can_get_berr_counter(const struct net_device *dev,
 {
 	struct pch_can_priv *priv = netdev_priv(dev);
 
-	bec->txerr = ioread32(&priv->regs->errc) & CAN_TEC;
-	bec->rxerr = (ioread32(&priv->regs->errc) & CAN_REC) >> 8;
+	bec->txerr = ioread32(&priv->regs->errc) & PCH_TEC;
+	bec->rxerr = (ioread32(&priv->regs->errc) & PCH_REC) >> 8;
 
 	return 0;
 }
@@ -1410,10 +1398,10 @@ static int __devinit pch_can_probe(struct pci_dev *pdev,
 
 	priv->can.clock.freq = PCH_CAN_CLK; /* Hz */
 	for (index = 0; index < PCH_RX_OBJ_NUM;)
-		priv->msg_obj[index++] = MSG_OBJ_RX;
+		priv->msg_obj[index++] = PCH_MSG_OBJ_RX;
 
 	for (index = index;  index < PCH_OBJ_NUM;)
-		priv->msg_obj[index++] = MSG_OBJ_TX;
+		priv->msg_obj[index++] = PCH_MSG_OBJ_TX;
 
 	netif_napi_add(ndev, &priv->napi, pch_can_rx_poll, PCH_RX_OBJ_NUM);
 
-- 
1.6.0.6

