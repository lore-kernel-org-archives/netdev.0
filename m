From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 3/4] amd-xgbe: Checkpatch driver fixes
Date: Wed, 3 Sep 2014 12:14:33 -0500
Message-ID: <20140903171433.9710.7915.stgit@tlendack-t1.amdoffice.net>
References: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0148.outbound.protection.outlook.com ([157.56.111.148]:20165
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932711AbaICRaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:30:03 -0400
In-Reply-To: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains fixes identified by checkpatch when run with the
strict option.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h  |   11 -----------
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c     |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c    |    6 +-----
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c     |    1 -
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    2 --
 11 files changed, 2 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index cc25a3a..caade30 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -271,7 +271,6 @@
 #define DMA_PBL_X8_DISABLE		0x00
 #define DMA_PBL_X8_ENABLE		0x01
 
-
 /* MAC register offsets */
 #define MAC_TCR				0x0000
 #define MAC_RCR				0x0004
@@ -792,7 +791,6 @@
 #define MTL_Q_DISABLED			0x00
 #define MTL_Q_ENABLED			0x02
 
-
 /* MTL traffic class register offsets
  *   Multiple traffic classes can be active.  The first class has registers
  *   that begin at 0x1100.  Each subsequent queue has registers that
@@ -815,7 +813,6 @@
 #define MTL_TSA_SP			0x00
 #define MTL_TSA_ETS			0x02
 
-
 /* PCS MMD select register offset
  *  The MMD select register is used for accessing PCS registers
  *  when the underlying APB3 interface is using indirect addressing.
@@ -825,7 +822,6 @@
  */
 #define PCS_MMD_SELECT			0xff
 
-
 /* Descriptor/Packet entry bit positions and sizes */
 #define RX_PACKET_ERRORS_CRC_INDEX		2
 #define RX_PACKET_ERRORS_CRC_WIDTH		1
@@ -929,7 +925,6 @@
 #define MDIO_AN_COMP_STAT		0x0030
 #endif
 
-
 /* Bit setting and getting macros
  *  The get macro will extract the current bit field value from within
  *  the variable
@@ -957,7 +952,6 @@ do {									\
 			      ((0x1 << (_width)) - 1)) << (_index)));	\
 } while (0)
 
-
 /* Bit setting and getting macros based on register fields
  *  The get macro uses the bit field definitions formed using the input
  *  names to extract the current bit field value from within the
@@ -986,7 +980,6 @@ do {									\
 		 _prefix##_##_field##_INDEX,				\
 		 _prefix##_##_field##_WIDTH, (_val))
 
-
 /* Macros for reading or writing registers
  *  The ioread macros will get bit fields or full values using the
  *  register definitions formed using the input names
@@ -1014,7 +1007,6 @@ do {									\
 	XGMAC_IOWRITE((_pdata), _reg, reg_val);				\
 } while (0)
 
-
 /* Macros for reading or writing MTL queue or traffic class registers
  *  Similar to the standard read and write macros except that the
  *  base register value is calculated by the queue or traffic class number
@@ -1041,7 +1033,6 @@ do {									\
 	XGMAC_MTL_IOWRITE((_pdata), (_n), _reg, reg_val);		\
 } while (0)
 
-
 /* Macros for reading or writing DMA channel registers
  *  Similar to the standard read and write macros except that the
  *  base register value is obtained from the ring
@@ -1066,7 +1057,6 @@ do {									\
 	XGMAC_DMA_IOWRITE((_channel), _reg, reg_val);			\
 } while (0)
 
-
 /* Macros for building, reading or writing register values or bits
  * within the register values of XPCS registers.
  */
@@ -1076,7 +1066,6 @@ do {									\
 #define XPCS_IOREAD(_pdata, _off)					\
 	ioread32((_pdata)->xpcs_regs + (_off))
 
-
 /* Macros for building, reading or writing register values or bits
  * using MDIO.  Different from above because of the use of standardized
  * Linux include values.  No shifting is performed with the bit
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
index 7d6a49b..8a50b01 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
@@ -120,7 +120,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static int xgbe_dcb_ieee_getets(struct net_device *netdev,
 				struct ieee_ets *ets)
 {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 346592d..978f9ec 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -121,7 +121,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static ssize_t xgbe_common_read(char __user *buffer, size_t count,
 				loff_t *ppos, unsigned int value)
 {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 1c5d62e..6fc5da0 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -117,7 +117,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static void xgbe_unmap_skb(struct xgbe_prv_data *, struct xgbe_ring_data *);
 
 static void xgbe_free_ring(struct xgbe_prv_data *pdata,
@@ -524,11 +523,8 @@ static void xgbe_realloc_skb(struct xgbe_channel *channel)
 
 		/* Allocate skb & assign to each rdesc */
 		skb = dev_alloc_skb(pdata->rx_buf_size);
-		if (skb == NULL) {
-			netdev_alert(pdata->netdev,
-				     "failed to allocate skb\n");
+		if (skb == NULL)
 			break;
-		}
 		skb_dma = dma_map_single(pdata->dev, skb->data,
 					 pdata->rx_buf_size, DMA_FROM_DEVICE);
 		if (dma_mapping_error(pdata->dev, skb_dma)) {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index edaca44..3be98e5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -122,7 +122,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static unsigned int xgbe_usec_to_riwt(struct xgbe_prv_data *pdata,
 				      unsigned int usec)
 {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index dc84f71..847da66 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -126,7 +126,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static int xgbe_poll(struct napi_struct *, int);
 static void xgbe_set_rx_mode(struct net_device *);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index a076aca..2289526 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -121,7 +121,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 struct xgbe_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int stat_size;
@@ -173,6 +172,7 @@ static const struct xgbe_stats xgbe_gstring_stats[] = {
 	XGMAC_MMC_STAT("rx_watchdog_errors", rxwatchdogerror),
 	XGMAC_MMC_STAT("rx_pause_frames", rxpauseframes),
 };
+
 #define XGBE_STATS_COUNT	ARRAY_SIZE(xgbe_gstring_stats)
 
 static void xgbe_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 8aa6a93..984161d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -128,7 +128,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(XGBE_DRV_VERSION);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 6d2221e..363b210 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -123,7 +123,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static int xgbe_mdio_read(struct mii_bus *mii, int prtad, int mmd_reg)
 {
 	struct xgbe_prv_data *pdata = mii->priv;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
index 37e64cf..a1bf9d1c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
@@ -122,7 +122,6 @@
 #include "xgbe.h"
 #include "xgbe-common.h"
 
-
 static cycle_t xgbe_cc_read(const struct cyclecounter *cc)
 {
 	struct xgbe_prv_data *pdata = container_of(cc,
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 07bf70a..84fe34c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -128,7 +128,6 @@
 #include <linux/net_tstamp.h>
 #include <net/dcbnl.h>
 
-
 #define XGBE_DRV_NAME		"amd-xgbe"
 #define XGBE_DRV_VERSION	"1.0.0-a"
 #define XGBE_DRV_DESC		"AMD 10 Gigabit Ethernet Driver"
@@ -198,7 +197,6 @@
 	((_ring)->rdata +					\
 	 ((_idx) & ((_ring)->rdesc_count - 1)))
 
-
 /* Default coalescing parameters */
 #define XGMAC_INIT_DMA_TX_USECS		50
 #define XGMAC_INIT_DMA_TX_FRAMES	25
