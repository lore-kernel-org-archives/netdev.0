From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v2 12/14] RDS: IB: mark rds_ib_fmr_wq static
Date: Wed, 30 Sep 2015 13:24:31 -0400
Message-ID: <1443633873-13359-13-git-send-email-santosh.shilimkar@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix below warning by marking rds_ib_fmr_wq static

net/rds/ib_rdma.c:87:25: warning: symbol 'rds_ib_fmr_wq' was not declared. Should it be static?

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 52d889a..bb62024 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -83,7 +83,7 @@ struct rds_ib_mr_pool {
 	struct ib_fmr_attr	fmr_attr;
 };
 
-struct workqueue_struct *rds_ib_fmr_wq;
+static struct workqueue_struct *rds_ib_fmr_wq;
 
 int rds_ib_fmr_init(void)
 {
-- 
1.9.1
