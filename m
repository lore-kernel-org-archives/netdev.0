From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1134/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:21 +0800
Message-ID: <20160802121921.25717-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: jhs@mojatatu.com, davem@davemloft.net, kadlec@blackhole.kfki.hu,
	kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:60228 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965502AbcHBM5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:47 -0400
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
 net/sched/sch_htb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d4b4218..8234fae 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -62,11 +62,11 @@ static int htb_hysteresis __read_mostly = 0; /* whether to use mode hysteresis f
 #endif
 
 /* Module parameter and sysfs export */
-module_param    (htb_hysteresis, int, 0640);
+module_param    (htb_hysteresis, int, S_IRUSR | S_IWUSR | S_IRGRP);
 MODULE_PARM_DESC(htb_hysteresis, "Hysteresis mode, less CPU load, less accurate");
 
 static int htb_rate_est = 0; /* htb classes have a default rate estimator */
-module_param(htb_rate_est, int, 0640);
+module_param(htb_rate_est, int, S_IRUSR | S_IWUSR | S_IRGRP);
 MODULE_PARM_DESC(htb_rate_est, "setup a default rate estimator (4sec 16sec) for htb classes");
 
 /* used internaly to keep status of single class */
-- 
2.9.2
