From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1112/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:33 +0800
Message-ID: <20160802121733.24261-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aarcange@redhat.com, aryabinin@virtuozzo.com
To: johannes@sipsolutions.net, davem@davemloft.net, jmorris@namei.org,
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
 net/mac80211/mlme.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 8d426f6..ca2f846 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -42,12 +42,12 @@
 #define IEEE80211_ASSOC_MAX_TRIES	3
 
 static int max_nullfunc_tries = 2;
-module_param(max_nullfunc_tries, int, 0644);
+module_param(max_nullfunc_tries, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_nullfunc_tries,
 		 "Maximum nullfunc tx tries before disconnecting (reason 4).");
 
 static int max_probe_tries = 5;
-module_param(max_probe_tries, int, 0644);
+module_param(max_probe_tries, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_probe_tries,
 		 "Maximum probe tries before disconnecting (reason 4).");
 
@@ -60,7 +60,7 @@ MODULE_PARM_DESC(max_probe_tries,
  * default to what we want.
  */
 static int beacon_loss_count = 7;
-module_param(beacon_loss_count, int, 0644);
+module_param(beacon_loss_count, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(beacon_loss_count,
 		 "Number of beacon intervals before we decide beacon was lost.");
 
@@ -75,7 +75,7 @@ MODULE_PARM_DESC(beacon_loss_count,
  * checking the connection still works.
  */
 static int probe_wait_ms = 500;
-module_param(probe_wait_ms, int, 0644);
+module_param(probe_wait_ms, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(probe_wait_ms,
 		 "Maximum time(ms) to wait for probe response"
 		 " before disconnecting (reason 4).");
-- 
2.9.2
