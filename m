From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1141/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:56 +0800
Message-ID: <20160802121956.26182-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, arnd@arndb.de, aryabinin@virtuozzo.com
To: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wimax@intel.com, anna.schumaker@netapp.com,
	kadlec@blackhole.kfki.hu, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46503 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965756AbcHBM5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:49 -0400
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
 net/wireless/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/core.c b/net/wireless/core.c
index ecca389..711ab8c 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -48,7 +48,7 @@ static struct dentry *ieee80211_debugfs_dir;
 struct workqueue_struct *cfg80211_wq;
 
 static bool cfg80211_disable_40mhz_24ghz;
-module_param(cfg80211_disable_40mhz_24ghz, bool, 0644);
+module_param(cfg80211_disable_40mhz_24ghz, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cfg80211_disable_40mhz_24ghz,
 		 "Disable 40MHz support in the 2.4GHz band");
 
-- 
2.9.2
