From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 24/25] bnx2x: Checkpatch compliance
Date: Wed, 13 Aug 2008 17:16:30 +0300
Message-ID: <1218636990.547.100.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2660 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756786AbYHMOQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checkpatch compliance
The latest version of checkpatch found the following style errors in the
code

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h         |    6 +-
 drivers/net/bnx2x_fw_defs.h |  154 +++++++++++++++++++++---------------------
 drivers/net/bnx2x_init.h    |   20 +++---
 drivers/net/bnx2x_link.c    |    8 +-
 drivers/net/bnx2x_main.c    |   16 ++--
 5 files changed, 102 insertions(+), 102 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 33437e5..b468f90 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -40,20 +40,20 @@
 #define DP(__mask, __fmt, __args...) do { \
 	if (bp->msglevel & (__mask)) \
 		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
-			bp->dev?(bp->dev->name):"?", ##__args); \
+			bp->dev ? (bp->dev->name) : "?", ##__args); \
 	} while (0)
 
 /* errors debug print */
 #define BNX2X_DBG_ERR(__fmt, __args...) do { \
 	if (bp->msglevel & NETIF_MSG_PROBE) \
 		printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
-			bp->dev?(bp->dev->name):"?", ##__args); \
+			bp->dev ? (bp->dev->name) : "?", ##__args); \
 	} while (0)
 
 /* for errors (never masked) */
 #define BNX2X_ERR(__fmt, __args...) do { \
 	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, __LINE__, \
-		bp->dev?(bp->dev->name):"?", ##__args); \
+		bp->dev ? (bp->dev->name) : "?", ##__args); \
 	} while (0)
 
 /* before we have a dev->name use dev_info() */
diff --git a/drivers/net/bnx2x_fw_defs.h b/drivers/net/bnx2x_fw_defs.h
index 6e35761..192fa98 100644
--- a/drivers/net/bnx2x_fw_defs.h
+++ b/drivers/net/bnx2x_fw_defs.h
@@ -9,171 +9,171 @@
 
 
 #define CSTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET? 0x7000 : 0x1000)
+	(IS_E1H_OFFSET ? 0x7000 : 0x1000)
 #define CSTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET? (0x7020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+	(IS_E1H_OFFSET ? (0x7020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define CSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET? (0x8522 + ((function>>1) * 0x40) + ((function&1) \
-	* 0x100) + (index * 0x4)) : (0x1922 + (function * 0x40) + (index \
-	* 0x4)))
+	(IS_E1H_OFFSET ? (0x8522 + ((function>>1) * 0x40) + \
+	((function&1) * 0x100) + (index * 0x4)) : (0x1922 + (function * \
+	0x40) + (index * 0x4)))
 #define CSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x8500 + ((function>>1) * 0x40) + ((function&1) \
-	* 0x100)) : (0x1900 + (function * 0x40)))
+	(IS_E1H_OFFSET ? (0x8500 + ((function>>1) * 0x40) + \
+	((function&1) * 0x100)) : (0x1900 + (function * 0x40)))
 #define CSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x8508 + ((function>>1) * 0x40) + ((function&1) \
-	* 0x100)) : (0x1908 + (function * 0x40)))
+	(IS_E1H_OFFSET ? (0x8508 + ((function>>1) * 0x40) + \
+	((function&1) * 0x100)) : (0x1908 + (function * 0x40)))
 #define CSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET? 0x11e8 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x11e8 : 0xffffffff)
 #define CSTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET? (0x8704 + (port * 0xf0)) : (0x1984 + (port * 0xc0)))
+	(IS_E1H_OFFSET ? (0x8704 + (port * 0xf0)) : (0x1984 + (port * 0xc0)))
 #define CSTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET? (0x801a + (port * 0x280) + (cpu_id * 0x28) + \
+	(IS_E1H_OFFSET ? (0x801a + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)) : (0x141a + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)))
 #define CSTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET? (0x8018 + (port * 0x280) + (cpu_id * 0x28) + \
+	(IS_E1H_OFFSET ? (0x8018 + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)) : (0x1418 + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)))
 #define CSTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET? (0x8000 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(IS_E1H_OFFSET ? (0x8000 + (port * 0x280) + (cpu_id * 0x28)) : \
 	(0x1400 + (port * 0x280) + (cpu_id * 0x28)))
 #define CSTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET? (0x8008 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(IS_E1H_OFFSET ? (0x8008 + (port * 0x280) + (cpu_id * 0x28)) : \
 	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
 #define CSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x1108 + (function * 0x8)) : (0x5108 + \
+	(IS_E1H_OFFSET ? (0x1108 + (function * 0x8)) : (0x5108 + \
 	(function * 0x8)))
 #define TSTORM_APPROXIMATE_MATCH_MULTICAST_FILTERING_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x31c0 + (function * 0x20)) : 0xffffffff)
+	(IS_E1H_OFFSET ? (0x31c0 + (function * 0x20)) : 0xffffffff)
 #define TSTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET? 0xa000 : 0x1000)
+	(IS_E1H_OFFSET ? 0xa000 : 0x1000)
 #define TSTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET? (0xa020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+	(IS_E1H_OFFSET ? (0xa020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define TSTORM_CLIENT_CONFIG_OFFSET(port, client_id) \
-	(IS_E1H_OFFSET? (0x3358 + (port * 0x3e8) + (client_id * 0x28)) : \
-	(0x9c8 + (port * 0x2f8) + (client_id * 0x28)))
+	(IS_E1H_OFFSET ? (0x3358 + (port * 0x3e8) + (client_id * 0x28)) \
+	: (0x9c8 + (port * 0x2f8) + (client_id * 0x28)))
 #define TSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET? (0xb01a + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0) + (index * 0x4)) : (0x141a + (function * 0x28) + (index * \
-	0x4)))
+	(IS_E1H_OFFSET ? (0xb01a + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0) + (index * 0x4)) : (0x141a + (function * \
+	0x28) + (index * 0x4)))
 #define TSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET? (0xb000 + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0)) : (0x1400 + (function * 0x28)))
+	(IS_E1H_OFFSET ? (0xb000 + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0)) : (0x1400 + (function * 0x28)))
 #define TSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET? (0xb008 + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0)) : (0x1408 + (function * 0x28)))
+	(IS_E1H_OFFSET ? (0xb008 + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0)) : (0x1408 + (function * 0x28)))
 #define TSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2b80 + (function * 0x8)) : (0x4b68 + \
+	(IS_E1H_OFFSET ? (0x2b80 + (function * 0x8)) : (0x4b68 + \
 	(function * 0x8)))
 #define TSTORM_FUNCTION_COMMON_CONFIG_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x3000 + (function * 0x38)) : (0x1500 + \
+	(IS_E1H_OFFSET ? (0x3000 + (function * 0x38)) : (0x1500 + \
 	(function * 0x38)))
 #define TSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET? 0x1ad0 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x1ad0 : 0xffffffff)
 #define TSTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET? (0xb144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
+	(IS_E1H_OFFSET ? (0xb144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
 #define TSTORM_INDIRECTION_TABLE_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x12c8 + (function * 0x80)) : (0x22c8 + \
+	(IS_E1H_OFFSET ? (0x12c8 + (function * 0x80)) : (0x22c8 + \
 	(function * 0x80)))
 #define TSTORM_INDIRECTION_TABLE_SIZE 0x80
 #define TSTORM_MAC_FILTER_CONFIG_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x3008 + (function * 0x38)) : (0x1508 + \
+	(IS_E1H_OFFSET ? (0x3008 + (function * 0x38)) : (0x1508 + \
 	(function * 0x38)))
 #define TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
 	(IS_E1H_OFFSET ? (0x2010 + (port * 0x5b0) + (stats_counter_id * \
 	0x50)) : (0x4000 + (port * 0x3f0) + (stats_counter_id * 0x38)))
 #define TSTORM_RX_PRODS_OFFSET(port, client_id) \
-	(IS_E1H_OFFSET? (0x3350 + (port * 0x3e8) + (client_id * 0x28)) : \
-	(0x9c0 + (port * 0x2f8) + (client_id * 0x28)))
+	(IS_E1H_OFFSET ? (0x3350 + (port * 0x3e8) + (client_id * 0x28)) \
+	: (0x9c0 + (port * 0x2f8) + (client_id * 0x28)))
 #define TSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2c00 + (function * 0x8)) : (0x4b88 + \
+	(IS_E1H_OFFSET ? (0x2c00 + (function * 0x8)) : (0x4b88 + \
 	(function * 0x8)))
-#define TSTORM_TPA_EXIST_OFFSET (IS_E1H_OFFSET? 0x3b30 : 0x1c20)
-#define USTORM_AGG_DATA_OFFSET (IS_E1H_OFFSET? 0xa040 : 0x2c10)
-#define USTORM_AGG_DATA_SIZE (IS_E1H_OFFSET? 0x2440 : 0x1200)
+#define TSTORM_TPA_EXIST_OFFSET (IS_E1H_OFFSET ? 0x3b30 : 0x1c20)
+#define USTORM_AGG_DATA_OFFSET (IS_E1H_OFFSET ? 0xa040 : 0x2c10)
+#define USTORM_AGG_DATA_SIZE (IS_E1H_OFFSET ? 0x2440 : 0x1200)
 #define USTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET? 0x8000 : 0x1000)
+	(IS_E1H_OFFSET ? 0x8000 : 0x1000)
 #define USTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET? (0x8020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+	(IS_E1H_OFFSET ? (0x8020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define USTORM_CQE_PAGE_BASE_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET? (0x3298 + (port * 0x258) + (clientId * 0x18)) : \
+	(IS_E1H_OFFSET ? (0x3298 + (port * 0x258) + (clientId * 0x18)) : \
 	(0x5450 + (port * 0x1c8) + (clientId * 0x18)))
 #define USTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET? (0x951a + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0) + (index * 0x4)) : (0x191a + (function * 0x28) + (index * \
-	0x4)))
+	(IS_E1H_OFFSET ? (0x951a + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0) + (index * 0x4)) : (0x191a + (function * \
+	0x28) + (index * 0x4)))
 #define USTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x9500 + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0)) : (0x1900 + (function * 0x28)))
+	(IS_E1H_OFFSET ? (0x9500 + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0)) : (0x1900 + (function * 0x28)))
 #define USTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x9508 + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0)) : (0x1908 + (function * 0x28)))
+	(IS_E1H_OFFSET ? (0x9508 + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0)) : (0x1908 + (function * 0x28)))
 #define USTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET? 0x2448 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x2448 : 0xffffffff)
 #define USTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET? (0x9644 + (port * 0xd0)) : (0x1954 + (port * 0xb8)))
+	(IS_E1H_OFFSET ? (0x9644 + (port * 0xd0)) : (0x1954 + (port * 0xb8)))
 #define USTORM_MAX_AGG_SIZE_OFFSET(port, clientId) \
-	(IS_E1H_OFFSET? (0x3290 + (port * 0x258) + (clientId * 0x18)) : \
+	(IS_E1H_OFFSET ? (0x3290 + (port * 0x258) + (clientId * 0x18)) : \
 	(0x5448 + (port * 0x1c8) + (clientId * 0x18)))
 #define USTORM_MEM_WORKAROUND_ADDRESS_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2408 + (function * 0x8)) : (0x5408 + \
+	(IS_E1H_OFFSET ? (0x2408 + (function * 0x8)) : (0x5408 + \
 	(function * 0x8)))
 #define USTORM_SB_HC_DISABLE_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET? (0x901a + (port * 0x280) + (cpu_id * 0x28) + \
+	(IS_E1H_OFFSET ? (0x901a + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)) : (0x141a + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)))
 #define USTORM_SB_HC_TIMEOUT_OFFSET(port, cpu_id, index) \
-	(IS_E1H_OFFSET? (0x9018 + (port * 0x280) + (cpu_id * 0x28) + \
+	(IS_E1H_OFFSET ? (0x9018 + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)) : (0x1418 + (port * 0x280) + (cpu_id * 0x28) + \
 	(index * 0x4)))
 #define USTORM_SB_HOST_SB_ADDR_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET? (0x9000 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(IS_E1H_OFFSET ? (0x9000 + (port * 0x280) + (cpu_id * 0x28)) : \
 	(0x1400 + (port * 0x280) + (cpu_id * 0x28)))
 #define USTORM_SB_HOST_STATUS_BLOCK_OFFSET(port, cpu_id) \
-	(IS_E1H_OFFSET? (0x9008 + (port * 0x280) + (cpu_id * 0x28)) : \
+	(IS_E1H_OFFSET ? (0x9008 + (port * 0x280) + (cpu_id * 0x28)) : \
 	(0x1408 + (port * 0x280) + (cpu_id * 0x28)))
 #define XSTORM_ASSERT_LIST_INDEX_OFFSET \
-	(IS_E1H_OFFSET? 0x9000 : 0x1000)
+	(IS_E1H_OFFSET ? 0x9000 : 0x1000)
 #define XSTORM_ASSERT_LIST_OFFSET(idx) \
-	(IS_E1H_OFFSET? (0x9020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
+	(IS_E1H_OFFSET ? (0x9020 + (idx * 0x10)) : (0x1020 + (idx * 0x10)))
 #define XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) \
-	(IS_E1H_OFFSET? (0x24a8 + (port * 0x40)) : (0x3ba0 + (port * 0x40)))
+	(IS_E1H_OFFSET ? (0x24a8 + (port * 0x40)) : (0x3ba0 + (port * 0x40)))
 #define XSTORM_DEF_SB_HC_DISABLE_OFFSET(function, index) \
-	(IS_E1H_OFFSET? (0xa01a + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0) + (index * 0x4)) : (0x141a + (function * 0x28) + (index * \
-	0x4)))
+	(IS_E1H_OFFSET ? (0xa01a + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0) + (index * 0x4)) : (0x141a + (function * \
+	0x28) + (index * 0x4)))
 #define XSTORM_DEF_SB_HOST_SB_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET? (0xa000 + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0)) : (0x1400 + (function * 0x28)))
+	(IS_E1H_OFFSET ? (0xa000 + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0)) : (0x1400 + (function * 0x28)))
 #define XSTORM_DEF_SB_HOST_STATUS_BLOCK_OFFSET(function) \
-	(IS_E1H_OFFSET? (0xa008 + ((function>>1) * 0x28) + ((function&1) \
-	* 0xa0)) : (0x1408 + (function * 0x28)))
+	(IS_E1H_OFFSET ? (0xa008 + ((function>>1) * 0x28) + \
+	((function&1) * 0xa0)) : (0x1408 + (function * 0x28)))
 #define XSTORM_E1HOV_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2ab8 + (function * 0x2)) : 0xffffffff)
+	(IS_E1H_OFFSET ? (0x2ab8 + (function * 0x2)) : 0xffffffff)
 #define XSTORM_ETH_STATS_QUERY_ADDR_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2418 + (function * 0x8)) : (0x3b70 + \
+	(IS_E1H_OFFSET ? (0x2418 + (function * 0x8)) : (0x3b70 + \
 	(function * 0x8)))
 #define XSTORM_FAIRNESS_PER_VN_VARS_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2568 + (function * 0x70)) : (0x3c60 + \
+	(IS_E1H_OFFSET ? (0x2568 + (function * 0x70)) : (0x3c60 + \
 	(function * 0x70)))
 #define XSTORM_FUNCTION_MODE_OFFSET \
-	(IS_E1H_OFFSET? 0x2ac8 : 0xffffffff)
+	(IS_E1H_OFFSET ? 0x2ac8 : 0xffffffff)
 #define XSTORM_HC_BTR_OFFSET(port) \
-	(IS_E1H_OFFSET? (0xa144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
+	(IS_E1H_OFFSET ? (0xa144 + (port * 0x30)) : (0x1454 + (port * 0x18)))
 #define XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, stats_counter_id) \
 	(IS_E1H_OFFSET ? (0xc000 + (port * 0x3f0) + (stats_counter_id * \
 	0x38)) : (0x3378 + (port * 0x3f0) + (stats_counter_id * 0x38)))
 #define XSTORM_RATE_SHAPING_PER_VN_VARS_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2528 + (function * 0x70)) : (0x3c20 + \
+	(IS_E1H_OFFSET ? (0x2528 + (function * 0x70)) : (0x3c20 + \
 	(function * 0x70)))
 #define XSTORM_SPQ_PAGE_BASE_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2000 + (function * 0x10)) : (0x3328 + \
+	(IS_E1H_OFFSET ? (0x2000 + (function * 0x10)) : (0x3328 + \
 	(function * 0x10)))
 #define XSTORM_SPQ_PROD_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x2008 + (function * 0x10)) : (0x3330 + \
+	(IS_E1H_OFFSET ? (0x2008 + (function * 0x10)) : (0x3330 + \
 	(function * 0x10)))
 #define XSTORM_STATS_FLAGS_OFFSET(function) \
-	(IS_E1H_OFFSET? (0x23d8 + (function * 0x8)) : (0x3b60 + \
+	(IS_E1H_OFFSET ? (0x23d8 + (function * 0x8)) : (0x3b60 + \
 	(function * 0x8)))
 #define COMMON_ASM_INVALID_ASSERT_OPCODE 0x0
 
diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index f62891b..130927c 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -72,26 +72,26 @@
 
 
 struct raw_op {
-	u32 op		:8;
-	u32 offset	:24;
+	u32 op:8;
+	u32 offset:24;
 	u32 raw_data;
 };
 
 struct op_read {
-	u32 op		:8;
-	u32 offset	:24;
+	u32 op:8;
+	u32 offset:24;
 	u32 pad;
 };
 
 struct op_write {
-	u32 op		:8;
-	u32 offset	:24;
+	u32 op:8;
+	u32 offset:24;
 	u32 val;
 };
 
 struct op_string_write {
-	u32 op		:8;
-	u32 offset	:24;
+	u32 op:8;
+	u32 offset:24;
 #ifdef __LITTLE_ENDIAN
 	u16 data_off;
 	u16 data_len;
@@ -102,8 +102,8 @@ struct op_string_write {
 };
 
 struct op_zero {
-	u32 op		:8;
-	u32 offset	:24;
+	u32 op:8;
+	u32 offset:24;
 	u32 len;
 };
 
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index d7398a3..8b92c6a 100755
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -755,10 +755,10 @@ static u32 bnx2x_get_emac_base(u32 ext_phy_type, u8 port)
 		emac_base = GRCBASE_EMAC0;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-		emac_base = (port) ? GRCBASE_EMAC0: GRCBASE_EMAC1;
+		emac_base = (port) ? GRCBASE_EMAC0 : GRCBASE_EMAC1;
 		break;
 	default:
-		emac_base = (port) ? GRCBASE_EMAC1: GRCBASE_EMAC0;
+		emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 		break;
 	}
 	return emac_base;
@@ -3549,7 +3549,7 @@ static void bnx2x_set_xgxs_loopback(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 
 	if (is_10g) {
-		 u32 md_devad;
+		u32 md_devad;
 
 		DP(NETIF_MSG_LINK, "XGXS 10G loopback enable\n");
 
@@ -4505,7 +4505,7 @@ static void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, u8 port, u8 phy_addr)
 }
 #define RESERVED_SIZE 256
 /* max application is 160K bytes - data at end of RAM */
-#define MAX_APP_SIZE 160*1024 - RESERVED_SIZE
+#define MAX_APP_SIZE (160*1024 - RESERVED_SIZE)
 
 /* Header is 14 bytes */
 #define HEADER_SIZE 14
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 1bbcdb2..f285f0b 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1858,14 +1858,14 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 	spio_reg = (REG_RD(bp, MISC_REG_SPIO) & MISC_REGISTERS_SPIO_FLOAT);
 
 	switch (mode) {
-	case MISC_REGISTERS_SPIO_OUTPUT_LOW :
+	case MISC_REGISTERS_SPIO_OUTPUT_LOW:
 		DP(NETIF_MSG_LINK, "Set SPIO %d -> output low\n", spio_num);
 		/* clear FLOAT and set CLR */
 		spio_reg &= ~(spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
 		spio_reg |=  (spio_mask << MISC_REGISTERS_SPIO_CLR_POS);
 		break;
 
-	case MISC_REGISTERS_SPIO_OUTPUT_HIGH :
+	case MISC_REGISTERS_SPIO_OUTPUT_HIGH:
 		DP(NETIF_MSG_LINK, "Set SPIO %d -> output high\n", spio_num);
 		/* clear FLOAT and set SET */
 		spio_reg &= ~(spio_mask << MISC_REGISTERS_SPIO_FLOAT_POS);
@@ -2759,7 +2759,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted)
 						HW_PRTY_ASSERT_SET_1) ||
 			    (attn.sig[2] & group_mask.sig[2] &
 						HW_PRTY_ASSERT_SET_2))
-			       BNX2X_ERR("FATAL HW block parity attention\n");
+				BNX2X_ERR("FATAL HW block parity attention\n");
 		}
 	}
 
@@ -2904,11 +2904,11 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 			/* underflow */ \
 			d_hi = m_hi - s_hi; \
 			if (d_hi > 0) { \
-			/* we can 'loan' 1 */ \
+				/* we can 'loan' 1 */ \
 				d_hi--; \
 				d_lo = m_lo + (UINT_MAX - s_lo) + 1; \
 			} else { \
-			/* m_hi <= s_hi */ \
+				/* m_hi <= s_hi */ \
 				d_hi = 0; \
 				d_lo = 0; \
 			} \
@@ -2918,7 +2918,7 @@ static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
 				d_hi = 0; \
 				d_lo = 0; \
 			} else { \
-			/* m_hi >= s_hi */ \
+				/* m_hi >= s_hi */ \
 				d_hi = m_hi - s_hi; \
 				d_lo = m_lo - s_lo; \
 			} \
@@ -3782,7 +3782,7 @@ static void bnx2x_stats_update(struct bnx2x *bp)
 			     bp->fp->rx_comp_cons),
 		       le16_to_cpu(*bp->fp->rx_cons_sb), nstats->rx_packets);
 		printk(KERN_DEBUG "  %s (Xoff events %u)  brb drops %u\n",
-		       netif_queue_stopped(bp->dev)? "Xoff" : "Xon",
+		       netif_queue_stopped(bp->dev) ? "Xoff" : "Xon",
 		       estats->driver_xoff, estats->brb_drop_lo);
 		printk(KERN_DEBUG "tstats: checksum_discard %u  "
 			"packets_too_big_discard %u  no_buff_discard %u  "
@@ -9610,7 +9610,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	tx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
-	nbd = skb_shinfo(skb)->nr_frags + ((pbd == NULL)? 1 : 2);
+	nbd = skb_shinfo(skb)->nr_frags + ((pbd == NULL) ? 1 : 2);
 	tx_bd->nbd = cpu_to_le16(nbd);
 	tx_bd->nbytes = cpu_to_le16(skb_headlen(skb));
 
-- 
1.5.3.2




