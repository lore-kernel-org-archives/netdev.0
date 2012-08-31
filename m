From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] RDMA/cxgb4: Update RDMA/cxgb4 due to macro definition removal in cxgb4 driver
Date: Fri, 31 Aug 2012 14:54:32 +0530
Message-ID: <1346405072-24561-3-git-send-email-vipul@chelsio.com>
References: <1346405072-24561-1-git-send-email-vipul@chelsio.com>
Cc: roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346405072-24561-1-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

cxgb4 driver removed the duplicate definitions of registers which requires
update in RDMA/cxgb4 driver.

Signed-off-by: Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Reviewed-by: Sivakumar Subramani <sivasu-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/qp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 45aedf1..5213bab 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -1155,7 +1155,7 @@ static int ring_kernel_db(struct c4iw_qp *qhp, u32 qid, u16 inc)
 		 */
 		if (cxgb4_dbfifo_count(qhp->rhp->rdev.lldi.ports[0], 1) <
 		    (qhp->rhp->rdev.lldi.dbfifo_int_thresh << 5)) {
-			writel(V_QID(qid) | V_PIDX(inc), qhp->wq.db);
+			writel(QID(qid) | PIDX(inc), qhp->wq.db);
 			break;
 		}
 		set_current_state(TASK_UNINTERRUPTIBLE);
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
