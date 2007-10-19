From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 8/8] [MV643XX_ETH] Remove unused register defines
Date: Fri, 19 Oct 2007 04:11:47 +0200
Message-ID: <20071019021147.GJ16037@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Manas Saksena <msaksena@marvell.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:44024 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764153AbXJSCLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 22:11:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of the register defines in drivers/net/mv643xx_eth.h aren't
used at all.  Nuke them -- we can always re-add them if/when we
need them, and meanwhile, they unnecessarily clutter up the
header file.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Acked-by: Tzachi Perelstein <tzachi@marvell.com>

Index: linux-2.6/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.6.orig/drivers/net/mv643xx_eth.h
+++ linux-2.6/drivers/net/mv643xx_eth.h
@@ -57,115 +57,28 @@
  */
 #define PHY_ADDR_REG				0x0000
 #define SMI_REG					0x0004
-#define UNIT_DEFAULT_ADDR_REG			0x0008
-#define UNIT_DEFAULTID_REG			0x000c
-#define UNIT_INTERRUPT_CAUSE_REG		0x0080
-#define UNIT_INTERRUPT_MASK_REG			0x0084
-#define UNIT_INTERNAL_USE_REG			0x04fc
-#define UNIT_ERROR_ADDR_REG			0x0094
-#define BAR_0					0x0200
-#define BAR_1					0x0208
-#define BAR_2					0x0210
-#define BAR_3					0x0218
-#define BAR_4					0x0220
-#define BAR_5					0x0228
-#define SIZE_REG_0				0x0204
-#define SIZE_REG_1				0x020c
-#define SIZE_REG_2				0x0214
-#define SIZE_REG_3				0x021c
-#define SIZE_REG_4				0x0224
-#define SIZE_REG_5				0x022c
-#define HEADERS_RETARGET_BASE_REG		0x0230
-#define HEADERS_RETARGET_CONTROL_REG		0x0234
-#define HIGH_ADDR_REMAP_REG_0			0x0280
-#define HIGH_ADDR_REMAP_REG_1			0x0284
-#define HIGH_ADDR_REMAP_REG_2			0x0288
-#define HIGH_ADDR_REMAP_REG_3			0x028c
-#define BASE_ADDR_ENABLE_REG			0x0290
 
 
 /*
  * Per-port registers.
  */
-#define ACCESS_PROTECTION_REG(p)			(0x0294 + ((p) << 2))
 #define PORT_CONFIG_REG(p)				(0x0400 + ((p) << 10))
 #define PORT_CONFIG_EXTEND_REG(p)			(0x0404 + ((p) << 10))
-#define MII_SERIAL_PARAMETRS_REG(p)			(0x0408 + ((p) << 10))
-#define GMII_SERIAL_PARAMETRS_REG(p)			(0x040c + ((p) << 10))
-#define VLAN_ETHERTYPE_REG(p)				(0x0410 + ((p) << 10))
 #define MAC_ADDR_LOW(p)					(0x0414 + ((p) << 10))
 #define MAC_ADDR_HIGH(p)				(0x0418 + ((p) << 10))
 #define SDMA_CONFIG_REG(p)				(0x041c + ((p) << 10))
-#define DSCP_0(p)					(0x0420 + ((p) << 10))
-#define DSCP_1(p)					(0x0424 + ((p) << 10))
-#define DSCP_2(p)					(0x0428 + ((p) << 10))
-#define DSCP_3(p)					(0x042c + ((p) << 10))
-#define DSCP_4(p)					(0x0430 + ((p) << 10))
-#define DSCP_5(p)					(0x0434 + ((p) << 10))
-#define DSCP_6(p)					(0x0438 + ((p) << 10))
 #define PORT_SERIAL_CONTROL_REG(p)			(0x043c + ((p) << 10))
-#define VLAN_PRIORITY_TAG_TO_PRIORITY(p)		(0x0440 + ((p) << 10))
 #define PORT_STATUS_REG(p)				(0x0444 + ((p) << 10))
 #define TRANSMIT_QUEUE_COMMAND_REG(p)			(0x0448 + ((p) << 10))
-#define TX_QUEUE_FIXED_PRIORITY(p)			(0x044c + ((p) << 10))
-#define PORT_TX_TOKEN_BUCKET_RATE_CONFIG(p)		(0x0450 + ((p) << 10))
 #define MAXIMUM_TRANSMIT_UNIT(p)			(0x0458 + ((p) << 10))
-#define PORT_MAXIMUM_TOKEN_BUCKET_SIZE(p)		(0x045c + ((p) << 10))
 #define INTERRUPT_CAUSE_REG(p)				(0x0460 + ((p) << 10))
 #define INTERRUPT_CAUSE_EXTEND_REG(p)			(0x0464 + ((p) << 10))
 #define INTERRUPT_MASK_REG(p)				(0x0468 + ((p) << 10))
 #define INTERRUPT_EXTEND_MASK_REG(p)			(0x046c + ((p) << 10))
-#define RX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0470 + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD_REG(p)			(0x0474 + ((p) << 10))
-#define RX_MINIMAL_FRAME_SIZE_REG(p)			(0x047c + ((p) << 10))
-#define RX_DISCARDED_FRAMES_COUNTER(p)			(0x0484 + ((p) << 10))
-#define PORT_DEBUG_0_REG(p)				(0x048c + ((p) << 10))
-#define PORT_DEBUG_1_REG(p)				(0x0490 + ((p) << 10))
-#define PORT_INTERNAL_ADDR_ERROR_REG(p)			(0x0494 + ((p) << 10))
-#define INTERNAL_USE_REG(p)				(0x04fc + ((p) << 10))
 #define RX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x060c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_1(p)			(0x061c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_2(p)			(0x062c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_3(p)			(0x063c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_4(p)			(0x064c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_5(p)			(0x065c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_6(p)			(0x066c + ((p) << 10))
-#define RX_CURRENT_QUEUE_DESC_PTR_7(p)			(0x067c + ((p) << 10))
 #define RECEIVE_QUEUE_COMMAND_REG(p)			(0x0680 + ((p) << 10))
-#define CURRENT_SERVED_TX_DESC_PTR(p)			(0x0684 + ((p) << 10))
 #define TX_CURRENT_QUEUE_DESC_PTR_0(p)			(0x06c0 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_1(p)			(0x06c4 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_2(p)			(0x06c8 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_3(p)			(0x06cc + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_4(p)			(0x06d0 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_5(p)			(0x06d4 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_6(p)			(0x06d8 + ((p) << 10))
-#define TX_CURRENT_QUEUE_DESC_PTR_7(p)			(0x06dc + ((p) << 10))
-#define TX_QUEUE_0_TOKEN_BUCKET_COUNT(p)		(0x0700 + ((p) << 10))
-#define TX_QUEUE_0_TOKEN_BUCKET_CONFIG(p)		(0x0704 + ((p) << 10))
-#define TX_QUEUE_0_ARBITER_CONFIG(p)			(0x0708 + ((p) << 10))
-#define TX_QUEUE_1_TOKEN_BUCKET_COUNT(p)		(0x0710 + ((p) << 10))
-#define TX_QUEUE_1_TOKEN_BUCKET_CONFIG(p)		(0x0714 + ((p) << 10))
-#define TX_QUEUE_1_ARBITER_CONFIG(p)			(0x0718 + ((p) << 10))
-#define TX_QUEUE_2_TOKEN_BUCKET_COUNT(p)		(0x0720 + ((p) << 10))
-#define TX_QUEUE_2_TOKEN_BUCKET_CONFIG(p)		(0x0724 + ((p) << 10))
-#define TX_QUEUE_2_ARBITER_CONFIG(p)			(0x0728 + ((p) << 10))
-#define TX_QUEUE_3_TOKEN_BUCKET_COUNT(p)		(0x0730 + ((p) << 10))
-#define TX_QUEUE_3_TOKEN_BUCKET_CONFIG(p)		(0x0734 + ((p) << 10))
-#define TX_QUEUE_3_ARBITER_CONFIG(p)			(0x0738 + ((p) << 10))
-#define TX_QUEUE_4_TOKEN_BUCKET_COUNT(p)		(0x0740 + ((p) << 10))
-#define TX_QUEUE_4_TOKEN_BUCKET_CONFIG(p)		(0x0744 + ((p) << 10))
-#define TX_QUEUE_4_ARBITER_CONFIG(p)			(0x0748 + ((p) << 10))
-#define TX_QUEUE_5_TOKEN_BUCKET_COUNT(p)		(0x0750 + ((p) << 10))
-#define TX_QUEUE_5_TOKEN_BUCKET_CONFIG(p)		(0x0754 + ((p) << 10))
-#define TX_QUEUE_5_ARBITER_CONFIG(p)			(0x0758 + ((p) << 10))
-#define TX_QUEUE_6_TOKEN_BUCKET_COUNT(p)		(0x0760 + ((p) << 10))
-#define TX_QUEUE_6_TOKEN_BUCKET_CONFIG(p)		(0x0764 + ((p) << 10))
-#define TX_QUEUE_6_ARBITER_CONFIG(p)			(0x0768 + ((p) << 10))
-#define TX_QUEUE_7_TOKEN_BUCKET_COUNT(p)		(0x0770 + ((p) << 10))
-#define TX_QUEUE_7_TOKEN_BUCKET_CONFIG(p)		(0x0774 + ((p) << 10))
-#define TX_QUEUE_7_ARBITER_CONFIG(p)			(0x0778 + ((p) << 10))
-#define PORT_TX_TOKEN_BUCKET_COUNT(p)			(0x0780 + ((p) << 10))
 #define MIB_COUNTERS_BASE(p)				(0x1000 + ((p) << 7))
 #define DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(p)	(0x1400 + ((p) << 10))
 #define DA_FILTER_OTHER_MULTICAST_TABLE_BASE(p)		(0x1500 + ((p) << 10))
