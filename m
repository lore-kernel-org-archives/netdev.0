From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 10/12] cxgb4, iw_cxgb4: move delayed ack macro definitions
Date: Sun, 13 Mar 2016 19:49:32 +0530
Message-ID: <39b60e2772f10d642a375429b42debc441caa370.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, swise@opengridcomputing.com,
	indranil@chelsio.com, kxie@chelsio.com, hariprasad@chelsio.com,
	varun@chelsio.com
To: nab@linux-iscsi.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
In-Reply-To: <cover.1457877852.git.varun@chelsio.com>
References: <cover.1457877852.git.varun@chelsio.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move delayed ack macro definitions to common
header file t4_msg.h.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h   | 9 ---------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 9 +++++++++
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 5f47e03..1e26669 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -753,13 +753,4 @@ struct fw_ri_wr {
 #define FW_RI_WR_P2PTYPE_G(x)	\
 	(((x) >> FW_RI_WR_P2PTYPE_S) & FW_RI_WR_P2PTYPE_M)
 
-#define RX_DACK_MODE_S    29
-#define RX_DACK_MODE_M    0x3
-#define RX_DACK_MODE_V(x) ((x) << RX_DACK_MODE_S)
-#define RX_DACK_MODE_G(x) (((x) >> RX_DACK_MODE_S) & RX_DACK_MODE_M)
-
-#define RX_DACK_CHANGE_S    31
-#define RX_DACK_CHANGE_V(x) ((x) << RX_DACK_CHANGE_S)
-#define RX_DACK_CHANGE_F    RX_DACK_CHANGE_V(1U)
-
 #endif /* _T4FW_RI_API_H_ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 03da7a7..a5641e2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -1040,6 +1040,15 @@ struct cpl_rx_data_ack {
 #define RX_FORCE_ACK_V(x) ((x) << RX_FORCE_ACK_S)
 #define RX_FORCE_ACK_F    RX_FORCE_ACK_V(1U)
 
+#define RX_DACK_MODE_S    29
+#define RX_DACK_MODE_M    0x3
+#define RX_DACK_MODE_V(x) ((x) << RX_DACK_MODE_S)
+#define RX_DACK_MODE_G(x) (((x) >> RX_DACK_MODE_S) & RX_DACK_MODE_M)
+
+#define RX_DACK_CHANGE_S    31
+#define RX_DACK_CHANGE_V(x) ((x) << RX_DACK_CHANGE_S)
+#define RX_DACK_CHANGE_F    RX_DACK_CHANGE_V(1U)
+
 struct cpl_rx_pkt {
 	struct rss_header rsshdr;
 	u8 opcode;
-- 
2.0.2
