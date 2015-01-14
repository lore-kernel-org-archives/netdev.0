From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH v2 1/2] fixup! net/macb: Adding comments to various #defs to make interpretation easier
Date: Wed, 14 Jan 2015 16:20:50 -0600
Message-ID: <1421274051-21588-1-git-send-email-xander.huff@ni.com>
References: <20150114.165220.2282566005036464131.davem@davemloft.net>
Cc: netdev@vger.kernel.org, jaeden.amero@ni.com, rich.tollerton@ni.com,
	ben.shelton@ni.com, brad.mouring@ni.com,
	linux-kernel@vger.kernel.org, cyrille.pitchen@atmel.com,
	Xander Huff <xander.huff@ni.com>
To: davem@davemloft.net, nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150114.165220.2282566005036464131.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Put #define comments into a single line.

Signed-off-by: Xander Huff <xander.huff@ni.com>
---
 drivers/net/ethernet/cadence/macb.h | 107 +++++++++---------------------------
 1 file changed, 26 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 378b218..d7b93d0 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -275,9 +275,7 @@
 #define MACB_THALT_SIZE				1
 #define MACB_NCR_TPF_OFFSET			11 /* Transmit pause frame */
 #define MACB_NCR_TPF_SIZE			1
-#define MACB_TZQ_OFFSET				12 /* Transmit zero quantum
-						    * pause frame
-						    */
+#define MACB_TZQ_OFFSET				12 /* Transmit zero quantum pause frame */
 #define MACB_TZQ_SIZE				1
 
 /* Bitfields in NCFGR */
@@ -299,9 +297,7 @@
 #define MACB_UNI_SIZE				1
 #define MACB_BIG_OFFSET				8 /* Receive 1536 byte frames */
 #define MACB_BIG_SIZE				1
-#define MACB_EAE_OFFSET				9 /* External address match
-						   * enable
-						   */
+#define MACB_EAE_OFFSET				9 /* External address match enable */
 #define MACB_EAE_SIZE				1
 #define MACB_CLK_OFFSET				10
 #define MACB_CLK_SIZE				2
@@ -313,9 +309,7 @@
 #define MACB_RM9200_RMII_SIZE			1  /* AT91RM9200 only */
 #define MACB_RBOF_OFFSET			14 /* Receive buffer offset */
 #define MACB_RBOF_SIZE				2
-#define MACB_RLCE_OFFSET			16 /* Length field error frame
-						    * discard
-						    */
+#define MACB_RLCE_OFFSET			16 /* Length field error frame discard */
 #define MACB_RLCE_SIZE				1
 #define MACB_DRFCS_OFFSET			17 /* FCS remove */
 #define MACB_DRFCS_SIZE				1
@@ -335,41 +329,22 @@
 #define GEM_RXCOEN_SIZE				1
 
 /* Constants for data bus width. */
-#define GEM_DBW32				0 /* 32 bit AMBA AHB data bus
-						   * width
-						   */
-#define GEM_DBW64				1 /* 64 bit AMBA AHB data bus
-						   * width
-						   */
-#define GEM_DBW128				2 /* 128 bit AMBA AHB data bus
-						   * width
-						   */
+#define GEM_DBW32				0 /* 32 bit AMBA AHB data bus width */
+#define GEM_DBW64				1 /* 64 bit AMBA AHB data bus width */
+#define GEM_DBW128				2 /* 128 bit AMBA AHB data bus width */
 
 /* Bitfields in DMACFG. */
-#define GEM_FBLDO_OFFSET			0 /* AHB fixed burst length for
-						   * DMA data operations
-						   */
+#define GEM_FBLDO_OFFSET			0 /* AHB fixed burst length for DMA data operations */
 #define GEM_FBLDO_SIZE				5
-#define GEM_ENDIA_OFFSET			7 /* AHB endian swap mode enable
-						   * for packet data accesses
-						   */
+#define GEM_ENDIA_OFFSET			7 /* AHB endian swap mode enable for packet data accesses */
 #define GEM_ENDIA_SIZE				1
-#define GEM_RXBMS_OFFSET			8 /* Receiver packet buffer
-						   * memory size select
-						   */
+#define GEM_RXBMS_OFFSET			8 /* Receiver packet buffer memory size select */
 #define GEM_RXBMS_SIZE				2
-#define GEM_TXPBMS_OFFSET			10 /* Transmitter packet buffer
-						    * memory size select
-						    */
+#define GEM_TXPBMS_OFFSET			10 /* Transmitter packet buffer memory size select */
 #define GEM_TXPBMS_SIZE				1
-#define GEM_TXCOEN_OFFSET			11 /* Transmitter IP, TCP and
-						    * UDP checksum generation
-						    * offload enable
-						    */
+#define GEM_TXCOEN_OFFSET			11 /* Transmitter IP, TCP and UDP checksum generation offload enable */
 #define GEM_TXCOEN_SIZE				1
-#define GEM_RXBS_OFFSET				16 /* DMA receive buffer size in
-						    * AHB system memory
-						    */
+#define GEM_RXBS_OFFSET				16 /* DMA receive buffer size in AHB system memory */
 #define GEM_RXBS_SIZE				8
 #define GEM_DDRP_OFFSET				24 /* disc_when_no_ahb */
 #define GEM_DDRP_SIZE				1
@@ -378,13 +353,9 @@
 /* Bitfields in NSR */
 #define MACB_NSR_LINK_OFFSET			0 /* pcs_link_state */
 #define MACB_NSR_LINK_SIZE			1
-#define MACB_MDIO_OFFSET			1 /* status of the mdio_in
-						   * pin
-						   */
+#define MACB_MDIO_OFFSET			1 /* status of the mdio_in pin */
 #define MACB_MDIO_SIZE				1
-#define MACB_IDLE_OFFSET			2 /* The PHY management logic is
-						   * idle (i.e. has completed)
-						   */
+#define MACB_IDLE_OFFSET			2 /* The PHY management logic is idle (i.e. has completed) */
 #define MACB_IDLE_SIZE				1
 
 /* Bitfields in TSR */
@@ -396,9 +367,7 @@
 #define MACB_TSR_RLE_SIZE			1
 #define MACB_TGO_OFFSET				3 /* Transmit go */
 #define MACB_TGO_SIZE				1
-#define MACB_BEX_OFFSET				4 /* Transmit frame corruption
-						   * due to AHB error
-						   */
+#define MACB_BEX_OFFSET				4 /* Transmit frame corruption due to AHB error */
 #define MACB_BEX_SIZE				1
 #define MACB_RM9200_BNQ_OFFSET			4 /* AT91RM9200 only */
 #define MACB_RM9200_BNQ_SIZE			1 /* AT91RM9200 only */
@@ -424,43 +393,23 @@
 #define MACB_RXUBR_SIZE				1
 #define MACB_TXUBR_OFFSET			3 /* TX used bit read */
 #define MACB_TXUBR_SIZE				1
-#define MACB_ISR_TUND_OFFSET			4 /* Enable trnasmit buffer
-						   * under run interrupt
-						   */
+#define MACB_ISR_TUND_OFFSET			4 /* Enable trnasmit buffer under run interrupt */
 #define MACB_ISR_TUND_SIZE			1
-#define MACB_ISR_RLE_OFFSET			5 /* Enable retry limit exceeded
-						   * or late collision interrupt
-						   */
+#define MACB_ISR_RLE_OFFSET			5 /* Enable retry limit exceeded or late collision interrupt */
 #define MACB_ISR_RLE_SIZE			1
-#define MACB_TXERR_OFFSET			6 /* Enable transmit frame
-						   * corruption due to AHB error
-						   * interrupt
-						   */
+#define MACB_TXERR_OFFSET			6 /* Enable transmit frame corruption due to AHB error interrupt */
 #define MACB_TXERR_SIZE				1
-#define MACB_TCOMP_OFFSET			7 /* Enable transmit complete
-						   * interrupt
-						   */
+#define MACB_TCOMP_OFFSET			7 /* Enable transmit complete interrupt */
 #define MACB_TCOMP_SIZE				1
-#define MACB_ISR_LINK_OFFSET			9 /* Enable link change
-						   * interrupt
-						   */
+#define MACB_ISR_LINK_OFFSET			9 /* Enable link change interrupt */
 #define MACB_ISR_LINK_SIZE			1
-#define MACB_ISR_ROVR_OFFSET			10 /* Enable receive overrun
-						    * interrupt
-						    */
+#define MACB_ISR_ROVR_OFFSET			10 /* Enable receive overrun interrupt */
 #define MACB_ISR_ROVR_SIZE			1
-#define MACB_HRESP_OFFSET			11 /* Enable hrsep not OK
-						    * interrupt
-						    */
+#define MACB_HRESP_OFFSET			11 /* Enable hrsep not OK interrupt */
 #define MACB_HRESP_SIZE				1
-#define MACB_PFR_OFFSET				12 /* Enable pause frame with
-						    * non-zero pause quantum
-						    * interrupt
-						    */
+#define MACB_PFR_OFFSET				12 /* Enable pause frame with non-zero pause quantum interrupt */
 #define MACB_PFR_SIZE				1
-#define MACB_PTZ_OFFSET				13 /* Enable pause time zero
-						    * interrupt
-						    */
+#define MACB_PTZ_OFFSET				13 /* Enable pause time zero interrupt */
 #define MACB_PTZ_SIZE				1
 
 /* Bitfields in MAN */
@@ -472,13 +421,9 @@
 #define MACB_REGA_SIZE				5
 #define MACB_PHYA_OFFSET			23 /* PHY address */
 #define MACB_PHYA_SIZE				5
-#define MACB_RW_OFFSET				28 /* Operation. 10 is read. 01
-						    * is write.
-						    */
+#define MACB_RW_OFFSET				28 /* Operation. 10 is read. 01 is write. */
 #define MACB_RW_SIZE				2
-#define MACB_SOF_OFFSET				30 /* Must be written to 1 for
-						    * Clause 22 operation
-						    */
+#define MACB_SOF_OFFSET				30 /* Must be written to 1 for Clause 22 operation */
 #define MACB_SOF_SIZE				2
 
 /* Bitfields in USRIO (AVR32) */
-- 
1.9.1
