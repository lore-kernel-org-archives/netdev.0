From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 4/9] s2io, rename BIT macro
Date: Sat, 18 Aug 2007 11:41:27 +0200 (CEST)
Message-ID: <27692164102679012429@wsc.cz>
References: <737828602404912540@wsc.cz>
Cc: <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cacti.profiwh.com ([85.93.165.66]:53394 "EHLO smtp.wsc.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752274AbXHRJkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2007 05:40:10 -0400
In-reply-to: <737828602404912540@wsc.cz>
Cc: <ram.vepa@neterion.com>
Cc: <santosh.rastapur@neterion.com>
Cc: <sivakumar.subramani@neterion.com>
Cc: <sreenivasa.honnur@neterion.com>
Cc: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s2io, rename BIT macro

BIT macro will be global definiton of (1<<x)

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit 0d66c4337fec02f0b9bd1c1fd783b60fbab5438b
tree c2027e1c366255dbec6ae061aed2c5cf809232b0
parent 6aec5d2e526e319488e6cdd627ca370086d458df
author Jiri Slaby <jirislaby@gmail.com> Wed, 15 Aug 2007 14:32:44 +0200
committer Jiri Slaby <jirislaby@gmail.com> Wed, 15 Aug 2007 14:32:44 +0200

 drivers/net/s2io-regs.h |  484 ++++++++++++++++++++++++-----------------------
 drivers/net/s2io.c      |   16 +-
 drivers/net/s2io.h      |   84 ++++----
 3 files changed, 292 insertions(+), 292 deletions(-)

diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
index cfa2679..0bebfd3 100644
--- a/drivers/net/s2io-regs.h
+++ b/drivers/net/s2io-regs.h
@@ -20,17 +20,17 @@ struct XENA_dev_config {
 
 /* General Control-Status Registers */
 	u64 general_int_status;
-#define GEN_INTR_TXPIC             BIT(0)
-#define GEN_INTR_TXDMA             BIT(1)
-#define GEN_INTR_TXMAC             BIT(2)
-#define GEN_INTR_TXXGXS            BIT(3)
-#define GEN_INTR_TXTRAFFIC         BIT(8)
-#define GEN_INTR_RXPIC             BIT(32)
-#define GEN_INTR_RXDMA             BIT(33)
-#define GEN_INTR_RXMAC             BIT(34)
-#define GEN_INTR_MC                BIT(35)
-#define GEN_INTR_RXXGXS            BIT(36)
-#define GEN_INTR_RXTRAFFIC         BIT(40)
+#define GEN_INTR_TXPIC             s2BIT(0)
+#define GEN_INTR_TXDMA             s2BIT(1)
+#define GEN_INTR_TXMAC             s2BIT(2)
+#define GEN_INTR_TXXGXS            s2BIT(3)
+#define GEN_INTR_TXTRAFFIC         s2BIT(8)
+#define GEN_INTR_RXPIC             s2BIT(32)
+#define GEN_INTR_RXDMA             s2BIT(33)
+#define GEN_INTR_RXMAC             s2BIT(34)
+#define GEN_INTR_MC                s2BIT(35)
+#define GEN_INTR_RXXGXS            s2BIT(36)
+#define GEN_INTR_RXTRAFFIC         s2BIT(40)
 #define GEN_ERROR_INTR             GEN_INTR_TXPIC | GEN_INTR_RXPIC | \
                                    GEN_INTR_TXDMA | GEN_INTR_RXDMA | \
                                    GEN_INTR_TXMAC | GEN_INTR_RXMAC | \
@@ -54,36 +54,36 @@ struct XENA_dev_config {
 
 
 	u64 adapter_status;
-#define ADAPTER_STATUS_TDMA_READY          BIT(0)
-#define ADAPTER_STATUS_RDMA_READY          BIT(1)
-#define ADAPTER_STATUS_PFC_READY           BIT(2)
-#define ADAPTER_STATUS_TMAC_BUF_EMPTY      BIT(3)
-#define ADAPTER_STATUS_PIC_QUIESCENT       BIT(5)
-#define ADAPTER_STATUS_RMAC_REMOTE_FAULT   BIT(6)
-#define ADAPTER_STATUS_RMAC_LOCAL_FAULT    BIT(7)
+#define ADAPTER_STATUS_TDMA_READY          s2BIT(0)
+#define ADAPTER_STATUS_RDMA_READY          s2BIT(1)
+#define ADAPTER_STATUS_PFC_READY           s2BIT(2)
+#define ADAPTER_STATUS_TMAC_BUF_EMPTY      s2BIT(3)
+#define ADAPTER_STATUS_PIC_QUIESCENT       s2BIT(5)
+#define ADAPTER_STATUS_RMAC_REMOTE_FAULT   s2BIT(6)
+#define ADAPTER_STATUS_RMAC_LOCAL_FAULT    s2BIT(7)
 #define ADAPTER_STATUS_RMAC_PCC_IDLE       vBIT(0xFF,8,8)
 #define ADAPTER_STATUS_RMAC_PCC_FOUR_IDLE  vBIT(0x0F,8,8)
 #define ADAPTER_STATUS_RC_PRC_QUIESCENT    vBIT(0xFF,16,8)
-#define ADAPTER_STATUS_MC_DRAM_READY       BIT(24)
-#define ADAPTER_STATUS_MC_QUEUES_READY     BIT(25)
-#define ADAPTER_STATUS_M_PLL_LOCK          BIT(30)
-#define ADAPTER_STATUS_P_PLL_LOCK          BIT(31)
+#define ADAPTER_STATUS_MC_DRAM_READY       s2BIT(24)
+#define ADAPTER_STATUS_MC_QUEUES_READY     s2BIT(25)
+#define ADAPTER_STATUS_M_PLL_LOCK          s2BIT(30)
+#define ADAPTER_STATUS_P_PLL_LOCK          s2BIT(31)
 
 	u64 adapter_control;
-#define ADAPTER_CNTL_EN                    BIT(7)
-#define ADAPTER_EOI_TX_ON                  BIT(15)
-#define ADAPTER_LED_ON                     BIT(23)
+#define ADAPTER_CNTL_EN                    s2BIT(7)
+#define ADAPTER_EOI_TX_ON                  s2BIT(15)
+#define ADAPTER_LED_ON                     s2BIT(23)
 #define ADAPTER_UDPI(val)                  vBIT(val,36,4)
-#define ADAPTER_WAIT_INT                   BIT(48)
-#define ADAPTER_ECC_EN                     BIT(55)
+#define ADAPTER_WAIT_INT                   s2BIT(48)
+#define ADAPTER_ECC_EN                     s2BIT(55)
 
 	u64 serr_source;
-#define SERR_SOURCE_PIC			BIT(0)
-#define SERR_SOURCE_TXDMA		BIT(1)
-#define SERR_SOURCE_RXDMA		BIT(2)
-#define SERR_SOURCE_MAC                 BIT(3)
-#define SERR_SOURCE_MC                  BIT(4)
-#define SERR_SOURCE_XGXS                BIT(5)
+#define SERR_SOURCE_PIC			s2BIT(0)
+#define SERR_SOURCE_TXDMA		s2BIT(1)
+#define SERR_SOURCE_RXDMA		s2BIT(2)
+#define SERR_SOURCE_MAC                 s2BIT(3)
+#define SERR_SOURCE_MC                  s2BIT(4)
+#define SERR_SOURCE_XGXS                s2BIT(5)
 #define	SERR_SOURCE_ANY			(SERR_SOURCE_PIC	| \
 					SERR_SOURCE_TXDMA	| \
 					SERR_SOURCE_RXDMA	| \
@@ -101,41 +101,41 @@ struct XENA_dev_config {
 #define	PCI_MODE_PCIX_M2_66		0x5
 #define	PCI_MODE_PCIX_M2_100		0x6
 #define	PCI_MODE_PCIX_M2_133		0x7
-#define	PCI_MODE_UNSUPPORTED		BIT(0)
-#define	PCI_MODE_32_BITS		BIT(8)
-#define	PCI_MODE_UNKNOWN_MODE		BIT(9)
+#define	PCI_MODE_UNSUPPORTED		s2BIT(0)
+#define	PCI_MODE_32_BITS		s2BIT(8)
+#define	PCI_MODE_UNKNOWN_MODE		s2BIT(9)
 
 	u8 unused_0[0x800 - 0x128];
 
 /* PCI-X Controller registers */
 	u64 pic_int_status;
 	u64 pic_int_mask;
-#define PIC_INT_TX                     BIT(0)
-#define PIC_INT_FLSH                   BIT(1)
-#define PIC_INT_MDIO                   BIT(2)
-#define PIC_INT_IIC                    BIT(3)
-#define PIC_INT_GPIO                   BIT(4)
-#define PIC_INT_RX                     BIT(32)
+#define PIC_INT_TX                     s2BIT(0)
+#define PIC_INT_FLSH                   s2BIT(1)
+#define PIC_INT_MDIO                   s2BIT(2)
+#define PIC_INT_IIC                    s2BIT(3)
+#define PIC_INT_GPIO                   s2BIT(4)
+#define PIC_INT_RX                     s2BIT(32)
 
 	u64 txpic_int_reg;
 	u64 txpic_int_mask;
-#define PCIX_INT_REG_ECC_SG_ERR                BIT(0)
-#define PCIX_INT_REG_ECC_DB_ERR                BIT(1)
-#define PCIX_INT_REG_FLASHR_R_FSM_ERR          BIT(8)
-#define PCIX_INT_REG_FLASHR_W_FSM_ERR          BIT(9)
-#define PCIX_INT_REG_INI_TX_FSM_SERR           BIT(10)
-#define PCIX_INT_REG_INI_TXO_FSM_ERR           BIT(11)
-#define PCIX_INT_REG_TRT_FSM_SERR              BIT(13)
-#define PCIX_INT_REG_SRT_FSM_SERR              BIT(14)
-#define PCIX_INT_REG_PIFR_FSM_SERR             BIT(15)
-#define PCIX_INT_REG_WRC_TX_SEND_FSM_SERR      BIT(21)
-#define PCIX_INT_REG_RRC_TX_REQ_FSM_SERR       BIT(23)
-#define PCIX_INT_REG_INI_RX_FSM_SERR           BIT(48)
-#define PCIX_INT_REG_RA_RX_FSM_SERR            BIT(50)
+#define PCIX_INT_REG_ECC_SG_ERR                s2BIT(0)
+#define PCIX_INT_REG_ECC_DB_ERR                s2BIT(1)
+#define PCIX_INT_REG_FLASHR_R_FSM_ERR          s2BIT(8)
+#define PCIX_INT_REG_FLASHR_W_FSM_ERR          s2BIT(9)
+#define PCIX_INT_REG_INI_TX_FSM_SERR           s2BIT(10)
+#define PCIX_INT_REG_INI_TXO_FSM_ERR           s2BIT(11)
+#define PCIX_INT_REG_TRT_FSM_SERR              s2BIT(13)
+#define PCIX_INT_REG_SRT_FSM_SERR              s2BIT(14)
+#define PCIX_INT_REG_PIFR_FSM_SERR             s2BIT(15)
+#define PCIX_INT_REG_WRC_TX_SEND_FSM_SERR      s2BIT(21)
+#define PCIX_INT_REG_RRC_TX_REQ_FSM_SERR       s2BIT(23)
+#define PCIX_INT_REG_INI_RX_FSM_SERR           s2BIT(48)
+#define PCIX_INT_REG_RA_RX_FSM_SERR            s2BIT(50)
 /*
-#define PCIX_INT_REG_WRC_RX_SEND_FSM_SERR      BIT(52)
-#define PCIX_INT_REG_RRC_RX_REQ_FSM_SERR       BIT(54)
-#define PCIX_INT_REG_RRC_RX_SPLIT_FSM_SERR     BIT(58)
+#define PCIX_INT_REG_WRC_RX_SEND_FSM_SERR      s2BIT(52)
+#define PCIX_INT_REG_RRC_RX_REQ_FSM_SERR       s2BIT(54)
+#define PCIX_INT_REG_RRC_RX_SPLIT_FSM_SERR     s2BIT(58)
 */
 	u64 txpic_alarms;
 	u64 rxpic_int_reg;
@@ -144,92 +144,92 @@ struct XENA_dev_config {
 
 	u64 flsh_int_reg;
 	u64 flsh_int_mask;
-#define PIC_FLSH_INT_REG_CYCLE_FSM_ERR         BIT(63)
-#define PIC_FLSH_INT_REG_ERR                   BIT(62)
+#define PIC_FLSH_INT_REG_CYCLE_FSM_ERR         s2BIT(63)
+#define PIC_FLSH_INT_REG_ERR                   s2BIT(62)
 	u64 flash_alarms;
 
 	u64 mdio_int_reg;
 	u64 mdio_int_mask;
-#define MDIO_INT_REG_MDIO_BUS_ERR              BIT(0)
-#define MDIO_INT_REG_DTX_BUS_ERR               BIT(8)
-#define MDIO_INT_REG_LASI                      BIT(39)
+#define MDIO_INT_REG_MDIO_BUS_ERR              s2BIT(0)
+#define MDIO_INT_REG_DTX_BUS_ERR               s2BIT(8)
+#define MDIO_INT_REG_LASI                      s2BIT(39)
 	u64 mdio_alarms;
 
 	u64 iic_int_reg;
 	u64 iic_int_mask;
-#define IIC_INT_REG_BUS_FSM_ERR                BIT(4)
-#define IIC_INT_REG_BIT_FSM_ERR                BIT(5)
-#define IIC_INT_REG_CYCLE_FSM_ERR              BIT(6)
-#define IIC_INT_REG_REQ_FSM_ERR                BIT(7)
-#define IIC_INT_REG_ACK_ERR                    BIT(8)
+#define IIC_INT_REG_BUS_FSM_ERR                s2BIT(4)
+#define IIC_INT_REG_BIT_FSM_ERR                s2BIT(5)
+#define IIC_INT_REG_CYCLE_FSM_ERR              s2BIT(6)
+#define IIC_INT_REG_REQ_FSM_ERR                s2BIT(7)
+#define IIC_INT_REG_ACK_ERR                    s2BIT(8)
 	u64 iic_alarms;
 
 	u8 unused4[0x08];
 
 	u64 gpio_int_reg;
-#define GPIO_INT_REG_DP_ERR_INT                BIT(0)
-#define GPIO_INT_REG_LINK_DOWN                 BIT(1)
-#define GPIO_INT_REG_LINK_UP                   BIT(2)
+#define GPIO_INT_REG_DP_ERR_INT                s2BIT(0)
+#define GPIO_INT_REG_LINK_DOWN                 s2BIT(1)
+#define GPIO_INT_REG_LINK_UP                   s2BIT(2)
 	u64 gpio_int_mask;
-#define GPIO_INT_MASK_LINK_DOWN                BIT(1)
-#define GPIO_INT_MASK_LINK_UP                  BIT(2)
+#define GPIO_INT_MASK_LINK_DOWN                s2BIT(1)
+#define GPIO_INT_MASK_LINK_UP                  s2BIT(2)
 	u64 gpio_alarms;
 
 	u8 unused5[0x38];
 
 	u64 tx_traffic_int;
-#define TX_TRAFFIC_INT_n(n)                    BIT(n)
+#define TX_TRAFFIC_INT_n(n)                    s2BIT(n)
 	u64 tx_traffic_mask;
 
 	u64 rx_traffic_int;
-#define RX_TRAFFIC_INT_n(n)                    BIT(n)
+#define RX_TRAFFIC_INT_n(n)                    s2BIT(n)
 	u64 rx_traffic_mask;
 
 /* PIC Control registers */
 	u64 pic_control;
-#define PIC_CNTL_RX_ALARM_MAP_1                BIT(0)
+#define PIC_CNTL_RX_ALARM_MAP_1                s2BIT(0)
 #define PIC_CNTL_SHARED_SPLITS(n)              vBIT(n,11,5)
 
 	u64 swapper_ctrl;
-#define SWAPPER_CTRL_PIF_R_FE                  BIT(0)
-#define SWAPPER_CTRL_PIF_R_SE                  BIT(1)
-#define SWAPPER_CTRL_PIF_W_FE                  BIT(8)
-#define SWAPPER_CTRL_PIF_W_SE                  BIT(9)
-#define SWAPPER_CTRL_TXP_FE                    BIT(16)
-#define SWAPPER_CTRL_TXP_SE                    BIT(17)
-#define SWAPPER_CTRL_TXD_R_FE                  BIT(18)
-#define SWAPPER_CTRL_TXD_R_SE                  BIT(19)
-#define SWAPPER_CTRL_TXD_W_FE                  BIT(20)
-#define SWAPPER_CTRL_TXD_W_SE                  BIT(21)
-#define SWAPPER_CTRL_TXF_R_FE                  BIT(22)
-#define SWAPPER_CTRL_TXF_R_SE                  BIT(23)
-#define SWAPPER_CTRL_RXD_R_FE                  BIT(32)
-#define SWAPPER_CTRL_RXD_R_SE                  BIT(33)
-#define SWAPPER_CTRL_RXD_W_FE                  BIT(34)
-#define SWAPPER_CTRL_RXD_W_SE                  BIT(35)
-#define SWAPPER_CTRL_RXF_W_FE                  BIT(36)
-#define SWAPPER_CTRL_RXF_W_SE                  BIT(37)
-#define SWAPPER_CTRL_XMSI_FE                   BIT(40)
-#define SWAPPER_CTRL_XMSI_SE                   BIT(41)
-#define SWAPPER_CTRL_STATS_FE                  BIT(48)
-#define SWAPPER_CTRL_STATS_SE                  BIT(49)
+#define SWAPPER_CTRL_PIF_R_FE                  s2BIT(0)
+#define SWAPPER_CTRL_PIF_R_SE                  s2BIT(1)
+#define SWAPPER_CTRL_PIF_W_FE                  s2BIT(8)
+#define SWAPPER_CTRL_PIF_W_SE                  s2BIT(9)
+#define SWAPPER_CTRL_TXP_FE                    s2BIT(16)
+#define SWAPPER_CTRL_TXP_SE                    s2BIT(17)
+#define SWAPPER_CTRL_TXD_R_FE                  s2BIT(18)
+#define SWAPPER_CTRL_TXD_R_SE                  s2BIT(19)
+#define SWAPPER_CTRL_TXD_W_FE                  s2BIT(20)
+#define SWAPPER_CTRL_TXD_W_SE                  s2BIT(21)
+#define SWAPPER_CTRL_TXF_R_FE                  s2BIT(22)
+#define SWAPPER_CTRL_TXF_R_SE                  s2BIT(23)
+#define SWAPPER_CTRL_RXD_R_FE                  s2BIT(32)
+#define SWAPPER_CTRL_RXD_R_SE                  s2BIT(33)
+#define SWAPPER_CTRL_RXD_W_FE                  s2BIT(34)
+#define SWAPPER_CTRL_RXD_W_SE                  s2BIT(35)
+#define SWAPPER_CTRL_RXF_W_FE                  s2BIT(36)
+#define SWAPPER_CTRL_RXF_W_SE                  s2BIT(37)
+#define SWAPPER_CTRL_XMSI_FE                   s2BIT(40)
+#define SWAPPER_CTRL_XMSI_SE                   s2BIT(41)
+#define SWAPPER_CTRL_STATS_FE                  s2BIT(48)
+#define SWAPPER_CTRL_STATS_SE                  s2BIT(49)
 
 	u64 pif_rd_swapper_fb;
 #define IF_RD_SWAPPER_FB                            0x0123456789ABCDEF
 
 	u64 scheduled_int_ctrl;
-#define SCHED_INT_CTRL_TIMER_EN                BIT(0)
-#define SCHED_INT_CTRL_ONE_SHOT                BIT(1)
+#define SCHED_INT_CTRL_TIMER_EN                s2BIT(0)
+#define SCHED_INT_CTRL_ONE_SHOT                s2BIT(1)
 #define SCHED_INT_CTRL_INT2MSI                 TBD
 #define SCHED_INT_PERIOD                       TBD
 
 	u64 txreqtimeout;
 #define TXREQTO_VAL(val)						vBIT(val,0,32)
-#define TXREQTO_EN								BIT(63)
+#define TXREQTO_EN								s2BIT(63)
 
 	u64 statsreqtimeout;
 #define STATREQTO_VAL(n)                       TBD
-#define STATREQTO_EN                           BIT(63)
+#define STATREQTO_EN                           s2BIT(63)
 
 	u64 read_retry_delay;
 	u64 read_retry_acceleration;
@@ -255,10 +255,10 @@ struct XENA_dev_config {
 
 	/* Automated statistics collection */
 	u64 stat_cfg;
-#define STAT_CFG_STAT_EN           BIT(0)
-#define STAT_CFG_ONE_SHOT_EN       BIT(1)
-#define STAT_CFG_STAT_NS_EN        BIT(8)
-#define STAT_CFG_STAT_RO           BIT(9)
+#define STAT_CFG_STAT_EN           s2BIT(0)
+#define STAT_CFG_ONE_SHOT_EN       s2BIT(1)
+#define STAT_CFG_STAT_NS_EN        s2BIT(8)
+#define STAT_CFG_STAT_RO           s2BIT(9)
 #define STAT_TRSF_PER(n)           TBD
 #define	PER_SEC					   0x208d5
 #define	SET_UPDT_PERIOD(n)		   vBIT((PER_SEC*n),32,32)
@@ -290,18 +290,18 @@ struct XENA_dev_config {
 #define	I2C_CONTROL_DEV_ID(id)		vBIT(id,1,3)
 #define	I2C_CONTROL_ADDR(addr)		vBIT(addr,5,11)
 #define	I2C_CONTROL_BYTE_CNT(cnt)	vBIT(cnt,22,2)
-#define	I2C_CONTROL_READ			BIT(24)
-#define	I2C_CONTROL_NACK			BIT(25)
+#define	I2C_CONTROL_READ			s2BIT(24)
+#define	I2C_CONTROL_NACK			s2BIT(25)
 #define	I2C_CONTROL_CNTL_START		vBIT(0xE,28,4)
 #define	I2C_CONTROL_CNTL_END(val)	(val & vBIT(0x1,28,4))
 #define	I2C_CONTROL_GET_DATA(val)	(u32)(val & 0xFFFFFFFF)
 #define	I2C_CONTROL_SET_DATA(val)	vBIT(val,32,32)
 
 	u64 gpio_control;
-#define GPIO_CTRL_GPIO_0		BIT(8)
+#define GPIO_CTRL_GPIO_0		s2BIT(8)
 	u64 misc_control;
-#define FAULT_BEHAVIOUR			BIT(0)
-#define EXT_REQ_EN			BIT(1)
+#define FAULT_BEHAVIOUR			s2BIT(0)
+#define EXT_REQ_EN			s2BIT(1)
 #define MISC_LINK_STABILITY_PRD(val)   vBIT(val,29,3)
 
 	u8 unused7_1[0x230 - 0x208];
@@ -317,13 +317,13 @@ struct XENA_dev_config {
 /* TxDMA registers */
 	u64 txdma_int_status;
 	u64 txdma_int_mask;
-#define TXDMA_PFC_INT                  BIT(0)
-#define TXDMA_TDA_INT                  BIT(1)
-#define TXDMA_PCC_INT                  BIT(2)
-#define TXDMA_TTI_INT                  BIT(3)
-#define TXDMA_LSO_INT                  BIT(4)
-#define TXDMA_TPA_INT                  BIT(5)
-#define TXDMA_SM_INT                   BIT(6)
+#define TXDMA_PFC_INT                  s2BIT(0)
+#define TXDMA_TDA_INT                  s2BIT(1)
+#define TXDMA_PCC_INT                  s2BIT(2)
+#define TXDMA_TTI_INT                  s2BIT(3)
+#define TXDMA_LSO_INT                  s2BIT(4)
+#define TXDMA_TPA_INT                  s2BIT(5)
+#define TXDMA_SM_INT                   s2BIT(6)
 	u64 pfc_err_reg;
 	u64 pfc_err_mask;
 	u64 pfc_err_alarm;
@@ -364,7 +364,7 @@ struct XENA_dev_config {
 #define X_MAX_FIFOS                        8
 #define X_FIFO_MAX_LEN                     0x1FFF	/*8191 */
 	u64 tx_fifo_partition_0;
-#define TX_FIFO_PARTITION_EN               BIT(0)
+#define TX_FIFO_PARTITION_EN               s2BIT(0)
 #define TX_FIFO_PARTITION_0_PRI(val)       vBIT(val,5,3)
 #define TX_FIFO_PARTITION_0_LEN(val)       vBIT(val,19,13)
 #define TX_FIFO_PARTITION_1_PRI(val)       vBIT(val,37,3)
@@ -404,16 +404,16 @@ struct XENA_dev_config {
 	u64 tx_w_round_robin_4;
 
 	u64 tti_command_mem;
-#define TTI_CMD_MEM_WE                     BIT(7)
-#define TTI_CMD_MEM_STROBE_NEW_CMD         BIT(15)
-#define TTI_CMD_MEM_STROBE_BEING_EXECUTED  BIT(15)
+#define TTI_CMD_MEM_WE                     s2BIT(7)
+#define TTI_CMD_MEM_STROBE_NEW_CMD         s2BIT(15)
+#define TTI_CMD_MEM_STROBE_BEING_EXECUTED  s2BIT(15)
 #define TTI_CMD_MEM_OFFSET(n)              vBIT(n,26,6)
 
 	u64 tti_data1_mem;
 #define TTI_DATA1_MEM_TX_TIMER_VAL(n)      vBIT(n,6,26)
 #define TTI_DATA1_MEM_TX_TIMER_AC_CI(n)    vBIT(n,38,2)
-#define TTI_DATA1_MEM_TX_TIMER_AC_EN       BIT(38)
-#define TTI_DATA1_MEM_TX_TIMER_CI_EN       BIT(39)
+#define TTI_DATA1_MEM_TX_TIMER_AC_EN       s2BIT(38)
+#define TTI_DATA1_MEM_TX_TIMER_CI_EN       s2BIT(39)
 #define TTI_DATA1_MEM_TX_URNG_A(n)         vBIT(n,41,7)
 #define TTI_DATA1_MEM_TX_URNG_B(n)         vBIT(n,49,7)
 #define TTI_DATA1_MEM_TX_URNG_C(n)         vBIT(n,57,7)
@@ -426,11 +426,11 @@ struct XENA_dev_config {
 
 /* Tx Protocol assist */
 	u64 tx_pa_cfg;
-#define TX_PA_CFG_IGNORE_FRM_ERR           BIT(1)
-#define TX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)
-#define TX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)
-#define	TX_PA_CFG_IGNORE_L2_ERR			   BIT(6)
-#define RX_PA_CFG_STRIP_VLAN_TAG		BIT(15)
+#define TX_PA_CFG_IGNORE_FRM_ERR           s2BIT(1)
+#define TX_PA_CFG_IGNORE_SNAP_OUI          s2BIT(2)
+#define TX_PA_CFG_IGNORE_LLC_CTRL          s2BIT(3)
+#define	TX_PA_CFG_IGNORE_L2_ERR			   s2BIT(6)
+#define RX_PA_CFG_STRIP_VLAN_TAG		s2BIT(15)
 
 /* Recent add, used only debug purposes. */
 	u64 pcc_enable;
@@ -444,10 +444,10 @@ struct XENA_dev_config {
 /* RxDMA Registers */
 	u64 rxdma_int_status;
 	u64 rxdma_int_mask;
-#define RXDMA_INT_RC_INT_M             BIT(0)
-#define RXDMA_INT_RPA_INT_M            BIT(1)
-#define RXDMA_INT_RDA_INT_M            BIT(2)
-#define RXDMA_INT_RTI_INT_M            BIT(3)
+#define RXDMA_INT_RC_INT_M             s2BIT(0)
+#define RXDMA_INT_RPA_INT_M            s2BIT(1)
+#define RXDMA_INT_RDA_INT_M            s2BIT(2)
+#define RXDMA_INT_RTI_INT_M            s2BIT(3)
 
 	u64 rda_err_reg;
 	u64 rda_err_mask;
@@ -505,49 +505,49 @@ struct XENA_dev_config {
 #endif
 	u64 prc_rxd0_n[RX_MAX_RINGS];
 	u64 prc_ctrl_n[RX_MAX_RINGS];
-#define PRC_CTRL_RC_ENABLED                    BIT(7)
-#define PRC_CTRL_RING_MODE                     (BIT(14)|BIT(15))
+#define PRC_CTRL_RC_ENABLED                    s2BIT(7)
+#define PRC_CTRL_RING_MODE                     (s2BIT(14)|s2BIT(15))
 #define PRC_CTRL_RING_MODE_1                   vBIT(0,14,2)
 #define PRC_CTRL_RING_MODE_3                   vBIT(1,14,2)
 #define PRC_CTRL_RING_MODE_5                   vBIT(2,14,2)
 #define PRC_CTRL_RING_MODE_x                   vBIT(3,14,2)
-#define PRC_CTRL_NO_SNOOP                      (BIT(22)|BIT(23))
-#define PRC_CTRL_NO_SNOOP_DESC                 BIT(22)
-#define PRC_CTRL_NO_SNOOP_BUFF                 BIT(23)
-#define PRC_CTRL_BIMODAL_INTERRUPT             BIT(37)
-#define PRC_CTRL_GROUP_READS                   BIT(38)
+#define PRC_CTRL_NO_SNOOP                      (s2BIT(22)|s2BIT(23))
+#define PRC_CTRL_NO_SNOOP_DESC                 s2BIT(22)
+#define PRC_CTRL_NO_SNOOP_BUFF                 s2BIT(23)
+#define PRC_CTRL_BIMODAL_INTERRUPT             s2BIT(37)
+#define PRC_CTRL_GROUP_READS                   s2BIT(38)
 #define PRC_CTRL_RXD_BACKOFF_INTERVAL(val)     vBIT(val,40,24)
 
 	u64 prc_alarm_action;
-#define PRC_ALARM_ACTION_RR_R0_STOP            BIT(3)
-#define PRC_ALARM_ACTION_RW_R0_STOP            BIT(7)
-#define PRC_ALARM_ACTION_RR_R1_STOP            BIT(11)
-#define PRC_ALARM_ACTION_RW_R1_STOP            BIT(15)
-#define PRC_ALARM_ACTION_RR_R2_STOP            BIT(19)
-#define PRC_ALARM_ACTION_RW_R2_STOP            BIT(23)
-#define PRC_ALARM_ACTION_RR_R3_STOP            BIT(27)
-#define PRC_ALARM_ACTION_RW_R3_STOP            BIT(31)
-#define PRC_ALARM_ACTION_RR_R4_STOP            BIT(35)
-#define PRC_ALARM_ACTION_RW_R4_STOP            BIT(39)
-#define PRC_ALARM_ACTION_RR_R5_STOP            BIT(43)
-#define PRC_ALARM_ACTION_RW_R5_STOP            BIT(47)
-#define PRC_ALARM_ACTION_RR_R6_STOP            BIT(51)
-#define PRC_ALARM_ACTION_RW_R6_STOP            BIT(55)
-#define PRC_ALARM_ACTION_RR_R7_STOP            BIT(59)
-#define PRC_ALARM_ACTION_RW_R7_STOP            BIT(63)
+#define PRC_ALARM_ACTION_RR_R0_STOP            s2BIT(3)
+#define PRC_ALARM_ACTION_RW_R0_STOP            s2BIT(7)
+#define PRC_ALARM_ACTION_RR_R1_STOP            s2BIT(11)
+#define PRC_ALARM_ACTION_RW_R1_STOP            s2BIT(15)
+#define PRC_ALARM_ACTION_RR_R2_STOP            s2BIT(19)
+#define PRC_ALARM_ACTION_RW_R2_STOP            s2BIT(23)
+#define PRC_ALARM_ACTION_RR_R3_STOP            s2BIT(27)
+#define PRC_ALARM_ACTION_RW_R3_STOP            s2BIT(31)
+#define PRC_ALARM_ACTION_RR_R4_STOP            s2BIT(35)
+#define PRC_ALARM_ACTION_RW_R4_STOP            s2BIT(39)
+#define PRC_ALARM_ACTION_RR_R5_STOP            s2BIT(43)
+#define PRC_ALARM_ACTION_RW_R5_STOP            s2BIT(47)
+#define PRC_ALARM_ACTION_RR_R6_STOP            s2BIT(51)
+#define PRC_ALARM_ACTION_RW_R6_STOP            s2BIT(55)
+#define PRC_ALARM_ACTION_RR_R7_STOP            s2BIT(59)
+#define PRC_ALARM_ACTION_RW_R7_STOP            s2BIT(63)
 
 /* Receive traffic interrupts */
 	u64 rti_command_mem;
-#define RTI_CMD_MEM_WE                          BIT(7)
-#define RTI_CMD_MEM_STROBE                      BIT(15)
-#define RTI_CMD_MEM_STROBE_NEW_CMD              BIT(15)
-#define RTI_CMD_MEM_STROBE_CMD_BEING_EXECUTED   BIT(15)
+#define RTI_CMD_MEM_WE                          s2BIT(7)
+#define RTI_CMD_MEM_STROBE                      s2BIT(15)
+#define RTI_CMD_MEM_STROBE_NEW_CMD              s2BIT(15)
+#define RTI_CMD_MEM_STROBE_CMD_BEING_EXECUTED   s2BIT(15)
 #define RTI_CMD_MEM_OFFSET(n)                   vBIT(n,29,3)
 
 	u64 rti_data1_mem;
 #define RTI_DATA1_MEM_RX_TIMER_VAL(n)      vBIT(n,3,29)
-#define RTI_DATA1_MEM_RX_TIMER_AC_EN       BIT(38)
-#define RTI_DATA1_MEM_RX_TIMER_CI_EN       BIT(39)
+#define RTI_DATA1_MEM_RX_TIMER_AC_EN       s2BIT(38)
+#define RTI_DATA1_MEM_RX_TIMER_CI_EN       s2BIT(39)
 #define RTI_DATA1_MEM_RX_URNG_A(n)         vBIT(n,41,7)
 #define RTI_DATA1_MEM_RX_URNG_B(n)         vBIT(n,49,7)
 #define RTI_DATA1_MEM_RX_URNG_C(n)         vBIT(n,57,7)
@@ -559,10 +559,10 @@ struct XENA_dev_config {
 #define RTI_DATA2_MEM_RX_UFC_D(n)          vBIT(n,48,16)
 
 	u64 rx_pa_cfg;
-#define RX_PA_CFG_IGNORE_FRM_ERR           BIT(1)
-#define RX_PA_CFG_IGNORE_SNAP_OUI          BIT(2)
-#define RX_PA_CFG_IGNORE_LLC_CTRL          BIT(3)
-#define RX_PA_CFG_IGNORE_L2_ERR            BIT(6)
+#define RX_PA_CFG_IGNORE_FRM_ERR           s2BIT(1)
+#define RX_PA_CFG_IGNORE_SNAP_OUI          s2BIT(2)
+#define RX_PA_CFG_IGNORE_LLC_CTRL          s2BIT(3)
+#define RX_PA_CFG_IGNORE_L2_ERR            s2BIT(6)
 
 	u64 unused_11_1;
 
@@ -578,38 +578,38 @@ struct XENA_dev_config {
 /* Media Access Controller Register */
 	u64 mac_int_status;
 	u64 mac_int_mask;
-#define MAC_INT_STATUS_TMAC_INT            BIT(0)
-#define MAC_INT_STATUS_RMAC_INT            BIT(1)
+#define MAC_INT_STATUS_TMAC_INT            s2BIT(0)
+#define MAC_INT_STATUS_RMAC_INT            s2BIT(1)
 
 	u64 mac_tmac_err_reg;
-#define TMAC_ERR_REG_TMAC_ECC_DB_ERR       BIT(15)
-#define TMAC_ERR_REG_TMAC_TX_BUF_OVRN      BIT(23)
-#define TMAC_ERR_REG_TMAC_TX_CRI_ERR       BIT(31)
+#define TMAC_ERR_REG_TMAC_ECC_DB_ERR       s2BIT(15)
+#define TMAC_ERR_REG_TMAC_TX_BUF_OVRN      s2BIT(23)
+#define TMAC_ERR_REG_TMAC_TX_CRI_ERR       s2BIT(31)
 	u64 mac_tmac_err_mask;
 	u64 mac_tmac_err_alarm;
 
 	u64 mac_rmac_err_reg;
-#define RMAC_ERR_REG_RX_BUFF_OVRN          BIT(0)
-#define RMAC_ERR_REG_RTS_ECC_DB_ERR        BIT(14)
-#define RMAC_ERR_REG_ECC_DB_ERR            BIT(15)
-#define RMAC_LINK_STATE_CHANGE_INT         BIT(31)
+#define RMAC_ERR_REG_RX_BUFF_OVRN          s2BIT(0)
+#define RMAC_ERR_REG_RTS_ECC_DB_ERR        s2BIT(14)
+#define RMAC_ERR_REG_ECC_DB_ERR            s2BIT(15)
+#define RMAC_LINK_STATE_CHANGE_INT         s2BIT(31)
 	u64 mac_rmac_err_mask;
 	u64 mac_rmac_err_alarm;
 
 	u8 unused14[0x100 - 0x40];
 
 	u64 mac_cfg;
-#define MAC_CFG_TMAC_ENABLE             BIT(0)
-#define MAC_CFG_RMAC_ENABLE             BIT(1)
-#define MAC_CFG_LAN_NOT_WAN             BIT(2)
-#define MAC_CFG_TMAC_LOOPBACK           BIT(3)
-#define MAC_CFG_TMAC_APPEND_PAD         BIT(4)
-#define MAC_CFG_RMAC_STRIP_FCS          BIT(5)
-#define MAC_CFG_RMAC_STRIP_PAD          BIT(6)
-#define MAC_CFG_RMAC_PROM_ENABLE        BIT(7)
-#define MAC_RMAC_DISCARD_PFRM           BIT(8)
-#define MAC_RMAC_BCAST_ENABLE           BIT(9)
-#define MAC_RMAC_ALL_ADDR_ENABLE        BIT(10)
+#define MAC_CFG_TMAC_ENABLE             s2BIT(0)
+#define MAC_CFG_RMAC_ENABLE             s2BIT(1)
+#define MAC_CFG_LAN_NOT_WAN             s2BIT(2)
+#define MAC_CFG_TMAC_LOOPBACK           s2BIT(3)
+#define MAC_CFG_TMAC_APPEND_PAD         s2BIT(4)
+#define MAC_CFG_RMAC_STRIP_FCS          s2BIT(5)
+#define MAC_CFG_RMAC_STRIP_PAD          s2BIT(6)
+#define MAC_CFG_RMAC_PROM_ENABLE        s2BIT(7)
+#define MAC_RMAC_DISCARD_PFRM           s2BIT(8)
+#define MAC_RMAC_BCAST_ENABLE           s2BIT(9)
+#define MAC_RMAC_ALL_ADDR_ENABLE        s2BIT(10)
 #define MAC_RMAC_INVLD_IPG_THR(val)     vBIT(val,16,8)
 
 	u64 tmac_avg_ipg;
@@ -621,14 +621,14 @@ struct XENA_dev_config {
 #define RMAC_MAX_PYLD_LEN_JUMBO_DEF vBIT(9600,2,14)
 
 	u64 rmac_err_cfg;
-#define RMAC_ERR_FCS                    BIT(0)
-#define RMAC_ERR_FCS_ACCEPT             BIT(1)
-#define RMAC_ERR_TOO_LONG               BIT(1)
-#define RMAC_ERR_TOO_LONG_ACCEPT        BIT(1)
-#define RMAC_ERR_RUNT                   BIT(2)
-#define RMAC_ERR_RUNT_ACCEPT            BIT(2)
-#define RMAC_ERR_LEN_MISMATCH           BIT(3)
-#define RMAC_ERR_LEN_MISMATCH_ACCEPT    BIT(3)
+#define RMAC_ERR_FCS                    s2BIT(0)
+#define RMAC_ERR_FCS_ACCEPT             s2BIT(1)
+#define RMAC_ERR_TOO_LONG               s2BIT(1)
+#define RMAC_ERR_TOO_LONG_ACCEPT        s2BIT(1)
+#define RMAC_ERR_RUNT                   s2BIT(2)
+#define RMAC_ERR_RUNT_ACCEPT            s2BIT(2)
+#define RMAC_ERR_LEN_MISMATCH           s2BIT(3)
+#define RMAC_ERR_LEN_MISMATCH_ACCEPT    s2BIT(3)
 
 	u64 rmac_cfg_key;
 #define RMAC_CFG_KEY(val)               vBIT(val,0,16)
@@ -639,15 +639,15 @@ struct XENA_dev_config {
 #define MAC_MC_ADDR_START_OFFSET    16
 #define MAC_MC_ALL_MC_ADDR_OFFSET   63	/* enables all multicast pkts */
 	u64 rmac_addr_cmd_mem;
-#define RMAC_ADDR_CMD_MEM_WE                    BIT(7)
+#define RMAC_ADDR_CMD_MEM_WE                    s2BIT(7)
 #define RMAC_ADDR_CMD_MEM_RD                    0
-#define RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD        BIT(15)
-#define RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING  BIT(15)
+#define RMAC_ADDR_CMD_MEM_STROBE_NEW_CMD        s2BIT(15)
+#define RMAC_ADDR_CMD_MEM_STROBE_CMD_EXECUTING  s2BIT(15)
 #define RMAC_ADDR_CMD_MEM_OFFSET(n)             vBIT(n,26,6)
 
 	u64 rmac_addr_data0_mem;
 #define RMAC_ADDR_DATA0_MEM_ADDR(n)    vBIT(n,0,48)
-#define RMAC_ADDR_DATA0_MEM_USER       BIT(48)
+#define RMAC_ADDR_DATA0_MEM_USER       s2BIT(48)
 
 	u64 rmac_addr_data1_mem;
 #define RMAC_ADDR_DATA1_MEM_MASK(n)    vBIT(n,0,48)
@@ -664,10 +664,10 @@ struct XENA_dev_config {
 	u64 tmac_ipg_cfg;
 
 	u64 rmac_pause_cfg;
-#define RMAC_PAUSE_GEN             BIT(0)
-#define RMAC_PAUSE_GEN_ENABLE      BIT(0)
-#define RMAC_PAUSE_RX              BIT(1)
-#define RMAC_PAUSE_RX_ENABLE       BIT(1)
+#define RMAC_PAUSE_GEN             s2BIT(0)
+#define RMAC_PAUSE_GEN_ENABLE      s2BIT(0)
+#define RMAC_PAUSE_RX              s2BIT(1)
+#define RMAC_PAUSE_RX_ENABLE       s2BIT(1)
 #define RMAC_PAUSE_HG_PTIME_DEF    vBIT(0xFFFF,16,16)
 #define RMAC_PAUSE_HG_PTIME(val)    vBIT(val,16,16)
 
@@ -698,29 +698,29 @@ struct XENA_dev_config {
 #define MAX_DIX_MAP                         4
 	u64 rts_dix_map_n[MAX_DIX_MAP];
 #define RTS_DIX_MAP_ETYPE(val)             vBIT(val,0,16)
-#define RTS_DIX_MAP_SCW(val)               BIT(val,21)
+#define RTS_DIX_MAP_SCW(val)               s2BIT(val,21)
 
 	u64 rts_q_alternates;
 	u64 rts_default_q;
 
 	u64 rts_ctrl;
-#define RTS_CTRL_IGNORE_SNAP_OUI           BIT(2)
-#define RTS_CTRL_IGNORE_LLC_CTRL           BIT(3)
+#define RTS_CTRL_IGNORE_SNAP_OUI           s2BIT(2)
+#define RTS_CTRL_IGNORE_LLC_CTRL           s2BIT(3)
 
 	u64 rts_pn_cam_ctrl;
-#define RTS_PN_CAM_CTRL_WE                 BIT(7)
-#define RTS_PN_CAM_CTRL_STROBE_NEW_CMD     BIT(15)
-#define RTS_PN_CAM_CTRL_STROBE_BEING_EXECUTED   BIT(15)
+#define RTS_PN_CAM_CTRL_WE                 s2BIT(7)
+#define RTS_PN_CAM_CTRL_STROBE_NEW_CMD     s2BIT(15)
+#define RTS_PN_CAM_CTRL_STROBE_BEING_EXECUTED   s2BIT(15)
 #define RTS_PN_CAM_CTRL_OFFSET(n)          vBIT(n,24,8)
 	u64 rts_pn_cam_data;
-#define RTS_PN_CAM_DATA_TCP_SELECT         BIT(7)
+#define RTS_PN_CAM_DATA_TCP_SELECT         s2BIT(7)
 #define RTS_PN_CAM_DATA_PORT(val)          vBIT(val,8,16)
 #define RTS_PN_CAM_DATA_SCW(val)           vBIT(val,24,8)
 
 	u64 rts_ds_mem_ctrl;
-#define RTS_DS_MEM_CTRL_WE                 BIT(7)
-#define RTS_DS_MEM_CTRL_STROBE_NEW_CMD     BIT(15)
-#define RTS_DS_MEM_CTRL_STROBE_CMD_BEING_EXECUTED   BIT(15)
+#define RTS_DS_MEM_CTRL_WE                 s2BIT(7)
+#define RTS_DS_MEM_CTRL_STROBE_NEW_CMD     s2BIT(15)
+#define RTS_DS_MEM_CTRL_STROBE_CMD_BEING_EXECUTED   s2BIT(15)
 #define RTS_DS_MEM_CTRL_OFFSET(n)          vBIT(n,26,6)
 	u64 rts_ds_mem_data;
 #define RTS_DS_MEM_DATA(n)                 vBIT(n,0,8)
@@ -734,22 +734,22 @@ struct XENA_dev_config {
 
 /* memory controller registers */
 	u64 mc_int_status;
-#define MC_INT_STATUS_MC_INT               BIT(0)
+#define MC_INT_STATUS_MC_INT               s2BIT(0)
 	u64 mc_int_mask;
-#define MC_INT_MASK_MC_INT                 BIT(0)
+#define MC_INT_MASK_MC_INT                 s2BIT(0)
 
 	u64 mc_err_reg;
-#define MC_ERR_REG_ECC_DB_ERR_L            BIT(14)
-#define MC_ERR_REG_ECC_DB_ERR_U            BIT(15)
-#define MC_ERR_REG_MIRI_ECC_DB_ERR_0       BIT(18)
-#define MC_ERR_REG_MIRI_ECC_DB_ERR_1       BIT(20)
-#define MC_ERR_REG_MIRI_CRI_ERR_0          BIT(22)
-#define MC_ERR_REG_MIRI_CRI_ERR_1          BIT(23)
-#define MC_ERR_REG_SM_ERR                  BIT(31)
-#define MC_ERR_REG_ECC_ALL_SNG		   (BIT(2) | BIT(3) | BIT(4) | BIT(5) |\
-					BIT(17) | BIT(19))
-#define MC_ERR_REG_ECC_ALL_DBL		   (BIT(10) | BIT(11) | BIT(12) |\
-					BIT(13) | BIT(18) | BIT(20))
+#define MC_ERR_REG_ECC_DB_ERR_L            s2BIT(14)
+#define MC_ERR_REG_ECC_DB_ERR_U            s2BIT(15)
+#define MC_ERR_REG_MIRI_ECC_DB_ERR_0       s2BIT(18)
+#define MC_ERR_REG_MIRI_ECC_DB_ERR_1       s2BIT(20)
+#define MC_ERR_REG_MIRI_CRI_ERR_0          s2BIT(22)
+#define MC_ERR_REG_MIRI_CRI_ERR_1          s2BIT(23)
+#define MC_ERR_REG_SM_ERR                  s2BIT(31)
+#define MC_ERR_REG_ECC_ALL_SNG		   (s2BIT(2) | s2BIT(3) | s2BIT(4) | s2BIT(5) |\
+					s2BIT(17) | s2BIT(19))
+#define MC_ERR_REG_ECC_ALL_DBL		   (s2BIT(10) | s2BIT(11) | s2BIT(12) |\
+					s2BIT(13) | s2BIT(18) | s2BIT(20))
 	u64 mc_err_mask;
 	u64 mc_err_alarm;
 
@@ -767,8 +767,8 @@ struct XENA_dev_config {
 #define RX_QUEUE_CFG_Q7_SZ(n)              vBIT(n,56,8)
 
 	u64 mc_rldram_mrs;
-#define	MC_RLDRAM_QUEUE_SIZE_ENABLE			BIT(39)
-#define	MC_RLDRAM_MRS_ENABLE				BIT(47)
+#define	MC_RLDRAM_QUEUE_SIZE_ENABLE			s2BIT(39)
+#define	MC_RLDRAM_MRS_ENABLE				s2BIT(47)
 
 	u64 mc_rldram_interleave;
 
@@ -781,11 +781,11 @@ struct XENA_dev_config {
 	u64 mc_rldram_ref_per;
 	u8 unused20[0x220 - 0x208];
 	u64 mc_rldram_test_ctrl;
-#define MC_RLDRAM_TEST_MODE		BIT(47)
-#define MC_RLDRAM_TEST_WRITE	BIT(7)
-#define MC_RLDRAM_TEST_GO		BIT(15)
-#define MC_RLDRAM_TEST_DONE		BIT(23)
-#define MC_RLDRAM_TEST_PASS		BIT(31)
+#define MC_RLDRAM_TEST_MODE		s2BIT(47)
+#define MC_RLDRAM_TEST_WRITE	s2BIT(7)
+#define MC_RLDRAM_TEST_GO		s2BIT(15)
+#define MC_RLDRAM_TEST_DONE		s2BIT(23)
+#define MC_RLDRAM_TEST_PASS		s2BIT(31)
 
 	u8 unused21[0x240 - 0x228];
 	u64 mc_rldram_test_add;
@@ -798,7 +798,7 @@ struct XENA_dev_config {
 
 	u8 unused24_1[0x360 - 0x308];
 	u64 mc_rldram_ctrl;
-#define	MC_RLDRAM_ENABLE_ODT		BIT(7)
+#define	MC_RLDRAM_ENABLE_ODT		s2BIT(7)
 
 	u8 unused24_2[0x640 - 0x368];
 	u64 mc_rldram_ref_per_herc;
@@ -816,14 +816,14 @@ struct XENA_dev_config {
 	/* XGXS control registers */
 
 	u64 xgxs_int_status;
-#define XGXS_INT_STATUS_TXGXS              BIT(0)
-#define XGXS_INT_STATUS_RXGXS              BIT(1)
+#define XGXS_INT_STATUS_TXGXS              s2BIT(0)
+#define XGXS_INT_STATUS_RXGXS              s2BIT(1)
 	u64 xgxs_int_mask;
-#define XGXS_INT_MASK_TXGXS                BIT(0)
-#define XGXS_INT_MASK_RXGXS                BIT(1)
+#define XGXS_INT_MASK_TXGXS                s2BIT(0)
+#define XGXS_INT_MASK_RXGXS                s2BIT(1)
 
 	u64 xgxs_txgxs_err_reg;
-#define TXGXS_ECC_DB_ERR                   BIT(15)
+#define TXGXS_ECC_DB_ERR                   s2BIT(15)
 	u64 xgxs_txgxs_err_mask;
 	u64 xgxs_txgxs_err_alarm;
 
@@ -846,10 +846,10 @@ struct XENA_dev_config {
 #define SPI_CONTROL_BYTECNT(cnt)	vBIT(cnt,29,3)
 #define SPI_CONTROL_CMD(cmd)		vBIT(cmd,32,8)
 #define SPI_CONTROL_ADDR(addr)		vBIT(addr,40,24)
-#define SPI_CONTROL_SEL1		BIT(4)
-#define SPI_CONTROL_REQ			BIT(7)
-#define SPI_CONTROL_NACK		BIT(5)
-#define SPI_CONTROL_DONE		BIT(6)
+#define SPI_CONTROL_SEL1		s2BIT(4)
+#define SPI_CONTROL_REQ			s2BIT(7)
+#define SPI_CONTROL_NACK		s2BIT(5)
+#define SPI_CONTROL_DONE		s2BIT(6)
 	u64 spi_data;
 #define SPI_DATA_WRITE(data,len)	vBIT(data,0,len)
 };
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 24feb00..e7225f2 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -1709,7 +1709,7 @@ static int init_nic(struct s2io_nic *nic)
 			MISC_LINK_STABILITY_PRD(3);
 		writeq(val64, &bar0->misc_control);
 		val64 = readq(&bar0->pic_control2);
-		val64 &= ~(BIT(13)|BIT(14)|BIT(15));
+		val64 &= ~(s2BIT(13)|s2BIT(14)|s2BIT(15));
 		writeq(val64, &bar0->pic_control2);
 	}
 	if (strstr(nic->product_name, "CX4")) {
@@ -2326,7 +2326,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 		}
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
 			((nic->rxd_mode == RXD_MODE_3B) &&
-				(rxdp->Control_2 & BIT(0)))) {
+				(rxdp->Control_2 & s2BIT(0)))) {
 			mac_control->rings[ring_no].rx_curr_put_info.
 					offset = off;
 			goto end;
@@ -2439,7 +2439,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, int ring_no)
 				rxdp->Control_2 |= SET_BUFFER2_SIZE_3
 								(dev->mtu + 4);
 			}
-			rxdp->Control_2 |= BIT(0);
+			rxdp->Control_2 |= s2BIT(0);
 		}
 		rxdp->Host_Control = (unsigned long) (skb);
 		if (alloc_tab & ((1 << rxsync_frequency) - 1))
@@ -3421,7 +3421,7 @@ static void s2io_reset(struct s2io_nic * sp)
 		pci_write_config_dword(sp->pdev, 0x68, 0x7C);
 
 		/* Clearing PCI_STATUS error reflected here */
-		writeq(BIT(62), &bar0->txpic_int_reg);
+		writeq(s2BIT(62), &bar0->txpic_int_reg);
 	}
 
 	/* Reset device statistics maintained by OS */
@@ -3619,7 +3619,7 @@ static int wait_for_msix_trans(struct s2io_nic *nic, int i)
 
 	do {
 		val64 = readq(&bar0->xmsi_access);
-		if (!(val64 & BIT(15)))
+		if (!(val64 & s2BIT(15)))
 			break;
 		mdelay(1);
 		cnt++;
@@ -3641,7 +3641,7 @@ static void restore_xmsi_data(struct s2io_nic *nic)
 	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
 		writeq(nic->msix_info[i].addr, &bar0->xmsi_address);
 		writeq(nic->msix_info[i].data, &bar0->xmsi_data);
-		val64 = (BIT(7) | BIT(15) | vBIT(i, 26, 6));
+		val64 = (s2BIT(7) | s2BIT(15) | vBIT(i, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, i)) {
 			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
@@ -3658,7 +3658,7 @@ static void store_xmsi_data(struct s2io_nic *nic)
 
 	/* Store and display */
 	for (i=0; i < MAX_REQUESTED_MSI_X; i++) {
-		val64 = (BIT(15) | vBIT(i, 26, 6));
+		val64 = (s2BIT(15) | vBIT(i, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, i)) {
 			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
@@ -4302,7 +4302,7 @@ static void s2io_updt_stats(struct s2io_nic *sp)
 		do {
 			udelay(100);
 			val64 = readq(&bar0->stat_cfg);
-			if (!(val64 & BIT(0)))
+			if (!(val64 & s2BIT(0)))
 				break;
 			cnt++;
 			if (cnt == 5)
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 92983ee..448f899 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -14,7 +14,7 @@
 #define _S2IO_H
 
 #define TBD 0
-#define BIT(loc)		(0x8000000000000000ULL >> (loc))
+#define s2BIT(loc)		(0x8000000000000000ULL >> (loc))
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
 #define INV(d)  ((d&0xff)<<24) | (((d>>8)&0xff)<<16) | (((d>>16)&0xff)<<8)| ((d>>24)&0xff)
 
@@ -449,42 +449,42 @@ struct TxFIFO_element {
 
 	u64 List_Control;
 #define TX_FIFO_LAST_TXD_NUM( val)     vBIT(val,0,8)
-#define TX_FIFO_FIRST_LIST             BIT(14)
-#define TX_FIFO_LAST_LIST              BIT(15)
+#define TX_FIFO_FIRST_LIST             s2BIT(14)
+#define TX_FIFO_LAST_LIST              s2BIT(15)
 #define TX_FIFO_FIRSTNLAST_LIST        vBIT(3,14,2)
-#define TX_FIFO_SPECIAL_FUNC           BIT(23)
-#define TX_FIFO_DS_NO_SNOOP            BIT(31)
-#define TX_FIFO_BUFF_NO_SNOOP          BIT(30)
+#define TX_FIFO_SPECIAL_FUNC           s2BIT(23)
+#define TX_FIFO_DS_NO_SNOOP            s2BIT(31)
+#define TX_FIFO_BUFF_NO_SNOOP          s2BIT(30)
 };
 
 /* Tx descriptor structure */
 struct TxD {
 	u64 Control_1;
 /* bit mask */
-#define TXD_LIST_OWN_XENA       BIT(7)
-#define TXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
+#define TXD_LIST_OWN_XENA       s2BIT(7)
+#define TXD_T_CODE              (s2BIT(12)|s2BIT(13)|s2BIT(14)|s2BIT(15))
 #define TXD_T_CODE_OK(val)      (|(val & TXD_T_CODE))
 #define GET_TXD_T_CODE(val)     ((val & TXD_T_CODE)<<12)
-#define TXD_GATHER_CODE         (BIT(22) | BIT(23))
-#define TXD_GATHER_CODE_FIRST   BIT(22)
-#define TXD_GATHER_CODE_LAST    BIT(23)
-#define TXD_TCP_LSO_EN          BIT(30)
-#define TXD_UDP_COF_EN          BIT(31)
-#define TXD_UFO_EN		BIT(31) | BIT(30)
+#define TXD_GATHER_CODE         (s2BIT(22) | s2BIT(23))
+#define TXD_GATHER_CODE_FIRST   s2BIT(22)
+#define TXD_GATHER_CODE_LAST    s2BIT(23)
+#define TXD_TCP_LSO_EN          s2BIT(30)
+#define TXD_UDP_COF_EN          s2BIT(31)
+#define TXD_UFO_EN		s2BIT(31) | s2BIT(30)
 #define TXD_TCP_LSO_MSS(val)    vBIT(val,34,14)
 #define TXD_UFO_MSS(val)	vBIT(val,34,14)
 #define TXD_BUFFER0_SIZE(val)   vBIT(val,48,16)
 
 	u64 Control_2;
-#define TXD_TX_CKO_CONTROL      (BIT(5)|BIT(6)|BIT(7))
-#define TXD_TX_CKO_IPV4_EN      BIT(5)
-#define TXD_TX_CKO_TCP_EN       BIT(6)
-#define TXD_TX_CKO_UDP_EN       BIT(7)
-#define TXD_VLAN_ENABLE         BIT(15)
+#define TXD_TX_CKO_CONTROL      (s2BIT(5)|s2BIT(6)|s2BIT(7))
+#define TXD_TX_CKO_IPV4_EN      s2BIT(5)
+#define TXD_TX_CKO_TCP_EN       s2BIT(6)
+#define TXD_TX_CKO_UDP_EN       s2BIT(7)
+#define TXD_VLAN_ENABLE         s2BIT(15)
 #define TXD_VLAN_TAG(val)       vBIT(val,16,16)
 #define TXD_INT_NUMBER(val)     vBIT(val,34,6)
-#define TXD_INT_TYPE_PER_LIST   BIT(47)
-#define TXD_INT_TYPE_UTILZ      BIT(46)
+#define TXD_INT_TYPE_PER_LIST   s2BIT(47)
+#define TXD_INT_TYPE_UTILZ      s2BIT(46)
 #define TXD_SET_MARKER         vBIT(0x6,0,4)
 
 	u64 Buffer_Pointer;
@@ -501,14 +501,14 @@ struct list_info_hold {
 struct RxD_t {
 	u64 Host_Control;	/* reserved for host */
 	u64 Control_1;
-#define RXD_OWN_XENA            BIT(7)
-#define RXD_T_CODE              (BIT(12)|BIT(13)|BIT(14)|BIT(15))
+#define RXD_OWN_XENA            s2BIT(7)
+#define RXD_T_CODE              (s2BIT(12)|s2BIT(13)|s2BIT(14)|s2BIT(15))
 #define RXD_FRAME_PROTO         vBIT(0xFFFF,24,8)
-#define RXD_FRAME_PROTO_IPV4    BIT(27)
-#define RXD_FRAME_PROTO_IPV6    BIT(28)
-#define RXD_FRAME_IP_FRAG	BIT(29)
-#define RXD_FRAME_PROTO_TCP     BIT(30)
-#define RXD_FRAME_PROTO_UDP     BIT(31)
+#define RXD_FRAME_PROTO_IPV4    s2BIT(27)
+#define RXD_FRAME_PROTO_IPV6    s2BIT(28)
+#define RXD_FRAME_IP_FRAG	s2BIT(29)
+#define RXD_FRAME_PROTO_TCP     s2BIT(30)
+#define RXD_FRAME_PROTO_UDP     s2BIT(31)
 #define TCP_OR_UDP_FRAME        (RXD_FRAME_PROTO_TCP | RXD_FRAME_PROTO_UDP)
 #define RXD_GET_L3_CKSUM(val)   ((u16)(val>> 16) & 0xFFFF)
 #define RXD_GET_L4_CKSUM(val)   ((u16)(val) & 0xFFFF)
@@ -972,26 +972,26 @@ static inline void SPECIAL_REG_WRITE(u64 val, void __iomem *addr, int order)
 /*  Interrupt masks for the general interrupt mask register */
 #define DISABLE_ALL_INTRS   0xFFFFFFFFFFFFFFFFULL
 
-#define TXPIC_INT_M         BIT(0)
-#define TXDMA_INT_M         BIT(1)
-#define TXMAC_INT_M         BIT(2)
-#define TXXGXS_INT_M        BIT(3)
-#define TXTRAFFIC_INT_M     BIT(8)
-#define PIC_RX_INT_M        BIT(32)
-#define RXDMA_INT_M         BIT(33)
-#define RXMAC_INT_M         BIT(34)
-#define MC_INT_M            BIT(35)
-#define RXXGXS_INT_M        BIT(36)
-#define RXTRAFFIC_INT_M     BIT(40)
+#define TXPIC_INT_M         s2BIT(0)
+#define TXDMA_INT_M         s2BIT(1)
+#define TXMAC_INT_M         s2BIT(2)
+#define TXXGXS_INT_M        s2BIT(3)
+#define TXTRAFFIC_INT_M     s2BIT(8)
+#define PIC_RX_INT_M        s2BIT(32)
+#define RXDMA_INT_M         s2BIT(33)
+#define RXMAC_INT_M         s2BIT(34)
+#define MC_INT_M            s2BIT(35)
+#define RXXGXS_INT_M        s2BIT(36)
+#define RXTRAFFIC_INT_M     s2BIT(40)
 
 /*  PIC level Interrupts TODO*/
 
 /*  DMA level Inressupts */
-#define TXDMA_PFC_INT_M     BIT(0)
-#define TXDMA_PCC_INT_M     BIT(2)
+#define TXDMA_PFC_INT_M     s2BIT(0)
+#define TXDMA_PCC_INT_M     s2BIT(2)
 
 /*  PFC block interrupts */
-#define PFC_MISC_ERR_1      BIT(0)	/* Interrupt to indicate FIFO full */
+#define PFC_MISC_ERR_1      s2BIT(0)	/* Interrupt to indicate FIFO full */
 
 /* PCC block interrupts. */
 #define	PCC_FB_ECC_ERR	   vBIT(0xff, 16, 8)	/* Interrupt to indicate
