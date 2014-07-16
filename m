From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4/iw_cxgb4: Move common defines to cxgb4
Date: Tue, 15 Jul 2014 19:55:50 -0700
Message-ID: <1405479353-2289-2-git-send-email-anish@chelsio.com>
References: <1405479353-2289-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma@vger.kernel.org, linux-scsi@vger.kernel.org,
	davem@davemloft.net, roland@purestorage.com, hch@infradead.org,
	michaelc@cs.wisc.edu, jbottomley@parallels.com, kxie@chelsio.com,
	leedom@chelsio.com, hariprasad@chelsio.com,
	swise@opengridcomputing.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1405479353-2289-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This define is used by cxgb4i and iw_cxgb4, moving to avoid code duplication

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Acked-by: Steve Wise <swise@opengridcomputing.com>
---
 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h   | 1 -
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
index 91289a051af9..5709e77faf7c 100644
--- a/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
+++ b/drivers/infiniband/hw/cxgb4/t4fw_ri_api.h
@@ -849,6 +849,5 @@ enum {                     /* TCP congestion control algorithms */
 #define G_CONG_CNTRL(x) (((x) >> S_CONG_CNTRL) & M_CONG_CNTRL)
 
 #define CONG_CNTRL_VALID   (1 << 18)
-#define T5_OPT_2_VALID       (1 << 31)
 
 #endif /* _T4FW_RI_API_H_ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index abb45809c0c8..64006327df83 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -276,6 +276,7 @@ struct cpl_pass_accept_rpl {
 #define WND_SCALE_EN(x)      ((x) << 28)
 #define TSTAMPS_EN(x)        ((x) << 29)
 #define SACK_EN(x)           ((x) << 30)
+#define T5_OPT_2_VALID	     ((1U) << 31)
 	__be64 opt0;
 };
 
-- 
2.0.1

