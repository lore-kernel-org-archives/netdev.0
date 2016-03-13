From: Varun Prakash <varun@chelsio.com>
Subject: [target-pending 01/12] cxgb4: add new ULD type CXGB4_ULD_ISCSIT
Date: Sun, 13 Mar 2016 19:49:23 +0530
Message-ID: <f36134e2c15bb3d7a00e2096d8c78353389420ea.1457877852.git.varun@chelsio.com>
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

Chelsio iSCSI target offload driver
will register with cxgb4 driver as ULD of type
CXGB4_ULD_ISCSIT.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index cf711d5..2f80e32 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -191,6 +191,7 @@ static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 enum cxgb4_uld {
 	CXGB4_ULD_RDMA,
 	CXGB4_ULD_ISCSI,
+	CXGB4_ULD_ISCSIT,
 	CXGB4_ULD_MAX
 };
 
-- 
2.0.2
