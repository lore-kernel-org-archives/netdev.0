From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next v2 1/4] cxgb4/iw_cxgb4: Move common defines to cxgb4
Date: Thu, 17 Jul 2014 00:18:15 -0700
Message-ID: <1405581498-28092-2-git-send-email-anish@chelsio.com>
References: <1405581498-28092-1-git-send-email-anish@chelsio.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405581498-28092-1-git-send-email-anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This define is used by cxgb4i and iw_cxgb4, moving to avoid code duplication

Signed-off-by: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Acked-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
