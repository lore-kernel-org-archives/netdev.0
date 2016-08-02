From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1131/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:07 +0800
Message-ID: <20160802121907.25519-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: santosh.shilimkar@oracle.com, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/rds/ib.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index b5342fd..07a783e 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -48,11 +48,11 @@ unsigned int rds_ib_mr_1m_pool_size = RDS_MR_1M_POOL_SIZE;
 unsigned int rds_ib_mr_8k_pool_size = RDS_MR_8K_POOL_SIZE;
 unsigned int rds_ib_retry_count = RDS_IB_DEFAULT_RETRY_COUNT;
 
-module_param(rds_ib_mr_1m_pool_size, int, 0444);
+module_param(rds_ib_mr_1m_pool_size, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rds_ib_mr_1m_pool_size, " Max number of 1M mr per HCA");
-module_param(rds_ib_mr_8k_pool_size, int, 0444);
+module_param(rds_ib_mr_8k_pool_size, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rds_ib_mr_8k_pool_size, " Max number of 8K mr per HCA");
-module_param(rds_ib_retry_count, int, 0444);
+module_param(rds_ib_retry_count, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rds_ib_retry_count, " Number of hw retries before reporting an error");
 
 /*
-- 
2.9.2
