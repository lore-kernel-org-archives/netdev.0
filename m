From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1102/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:16:47 +0800
Message-ID: <20160802121647.23598-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
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
 net/ipv4/tcp_cdg.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index 03725b2..aac4391 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -40,20 +40,20 @@ static unsigned int use_ineff __read_mostly = 5;
 static bool use_shadow __read_mostly = true;
 static bool use_tolerance __read_mostly;
 
-module_param(window, int, 0444);
+module_param(window, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(window, "gradient window size (power of two <= 256)");
-module_param(backoff_beta, uint, 0644);
+module_param(backoff_beta, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(backoff_beta, "backoff beta (0-1024)");
-module_param(backoff_factor, uint, 0644);
+module_param(backoff_factor, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(backoff_factor, "backoff probability scale factor");
-module_param(hystart_detect, uint, 0644);
+module_param(hystart_detect, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hystart_detect, "use Hybrid Slow start "
 		 "(0: disabled, 1: ACK train, 2: delay threshold, 3: both)");
-module_param(use_ineff, uint, 0644);
+module_param(use_ineff, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_ineff, "use ineffectual backoff detection (threshold)");
-module_param(use_shadow, bool, 0644);
+module_param(use_shadow, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_shadow, "use shadow window heuristic");
-module_param(use_tolerance, bool, 0644);
+module_param(use_tolerance, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_tolerance, "use loss tolerance heuristic");
 
 struct minmax {
-- 
2.9.2
