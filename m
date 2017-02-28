From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/1] rds: ib: add the static type to the variables
Date: Tue, 28 Feb 2017 01:45:40 -0500
Message-ID: <1488264340-20044-1-git-send-email-yanjun.zhu@oracle.com>
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The variables rds_ib_mr_1m_pool_size and rds_ib_mr_8k_pool_size
are used only in the ib.c file. As such, the static type is
added to limit them in this file.

Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib.c    | 4 ++--
 net/rds/ib_mr.h | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 8d70884..ecff01b 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -45,8 +45,8 @@
 #include "ib.h"
 #include "ib_mr.h"
 
-unsigned int rds_ib_mr_1m_pool_size = RDS_MR_1M_POOL_SIZE;
-unsigned int rds_ib_mr_8k_pool_size = RDS_MR_8K_POOL_SIZE;
+static unsigned int rds_ib_mr_1m_pool_size = RDS_MR_1M_POOL_SIZE;
+static unsigned int rds_ib_mr_8k_pool_size = RDS_MR_8K_POOL_SIZE;
 unsigned int rds_ib_retry_count = RDS_IB_DEFAULT_RETRY_COUNT;
 
 module_param(rds_ib_mr_1m_pool_size, int, 0444);
diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index 24c086d..5d6e98a 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -107,8 +107,6 @@ struct rds_ib_mr_pool {
 };
 
 extern struct workqueue_struct *rds_ib_mr_wq;
-extern unsigned int rds_ib_mr_1m_pool_size;
-extern unsigned int rds_ib_mr_8k_pool_size;
 extern bool prefer_frmr;
 
 struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_dev,
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
