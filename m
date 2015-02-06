From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/9] be2net: replace (1 << x) with BIT(x)
Date: Fri, 6 Feb 2015 08:18:36 -0500
Message-ID: <1423228723-10919-3-git-send-email-sathya.perla@emulex.com>
References: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:28175 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937AbbBFNPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:39 -0500
In-Reply-To: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

BIT(x) is the preffered usage.
Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 18 +++++++++---------
 drivers/net/ethernet/emulex/benet/be_cmds.h |  8 ++++----
 drivers/net/ethernet/emulex/benet/be_hw.h   |  4 ++--
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 3b1d59d..9869556 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -361,15 +361,15 @@ enum vf_state {
 	ASSIGNED = 1
 };
 
-#define BE_FLAGS_LINK_STATUS_INIT		1
-#define BE_FLAGS_SRIOV_ENABLED			(1 << 2)
-#define BE_FLAGS_WORKER_SCHEDULED		(1 << 3)
-#define BE_FLAGS_VLAN_PROMISC			(1 << 4)
-#define BE_FLAGS_MCAST_PROMISC			(1 << 5)
-#define BE_FLAGS_NAPI_ENABLED			(1 << 9)
-#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		(1 << 11)
-#define BE_FLAGS_VXLAN_OFFLOADS			(1 << 12)
-#define BE_FLAGS_SETUP_DONE			(1 << 13)
+#define BE_FLAGS_LINK_STATUS_INIT		BIT(1)
+#define BE_FLAGS_SRIOV_ENABLED			BIT(2)
+#define BE_FLAGS_WORKER_SCHEDULED		BIT(3)
+#define BE_FLAGS_VLAN_PROMISC			BIT(4)
+#define BE_FLAGS_MCAST_PROMISC			BIT(5)
+#define BE_FLAGS_NAPI_ENABLED			BIT(6)
+#define BE_FLAGS_QNQ_ASYNC_EVT_RCVD		BIT(7)
+#define BE_FLAGS_VXLAN_OFFLOADS			BIT(8)
+#define BE_FLAGS_SETUP_DONE			BIT(9)
 
 #define BE_UC_PMAC_COUNT			30
 #define BE_VF_UC_PMAC_COUNT			2
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index c2701cc..c231e45 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -44,10 +44,10 @@ struct be_mcc_wrb {
 	} payload;
 };
 
-#define CQE_FLAGS_VALID_MASK 		(1 << 31)
-#define CQE_FLAGS_ASYNC_MASK 		(1 << 30)
-#define CQE_FLAGS_COMPLETED_MASK 	(1 << 28)
-#define CQE_FLAGS_CONSUMED_MASK 	(1 << 27)
+#define CQE_FLAGS_VALID_MASK		BIT(31)
+#define CQE_FLAGS_ASYNC_MASK		BIT(30)
+#define CQE_FLAGS_COMPLETED_MASK	BIT(28)
+#define CQE_FLAGS_CONSUMED_MASK		BIT(27)
 
 /* Completion Status */
 enum mcc_base_status {
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 8e91ae8..a8593aa 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -75,7 +75,7 @@
  * atomically without having to arbitrate for the PCI Interrupt Disable bit
  * with the OS.
  */
-#define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK	(1 << 29) /* bit 29 */
+#define MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK	BIT(29) /* bit 29 */
 
 /********* PCI Function Capability *********/
 #define BE_FUNCTION_CAPS_RSS			0x2
@@ -224,7 +224,7 @@ struct amap_eth_hdr_wrb {
 } __packed;
 
 #define TX_HDR_WRB_COMPL		1		/* word 2 */
-#define TX_HDR_WRB_EVT			(1 << 1)	/* word 2 */
+#define TX_HDR_WRB_EVT			BIT(1)		/* word 2 */
 #define TX_HDR_WRB_NUM_SHIFT		13		/* word 2: bits 13:17 */
 #define TX_HDR_WRB_NUM_MASK		0x1F		/* word 2: bits 13:17 */
 
-- 
2.2.0
