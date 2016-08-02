From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1132/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:12 +0800
Message-ID: <20160802121912.25585-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: santosh.shilimkar@oracle.com, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27991 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965820AbcHBM5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/rds/send.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index b1962f8..8d2fe20 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -53,7 +53,7 @@
  * drained the queue).
  */
 static int send_batch_count = SZ_1K;
-module_param(send_batch_count, int, 0444);
+module_param(send_batch_count, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(send_batch_count, " batch factor when working the send queue");
 
 static void rds_send_remove_from_sock(struct list_head *messages, int status);
-- 
2.9.2
