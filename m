From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1142/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:20:01 +0800
Message-ID: <20160802122001.26248-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, arnd@arndb.de, aryabinin@virtuozzo.com
To: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wimax@intel.com, anna.schumaker@netapp.com,
	kadlec@blackhole.kfki.hu, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7023 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965884AbcHBM5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:50 -0400
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
 net/wireless/reg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 5dbac37..1435e1b 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -261,7 +261,7 @@ static const struct ieee80211_regdomain *cfg80211_world_regdom =
 static char *ieee80211_regdom = "00";
 static char user_alpha2[2];
 
-module_param(ieee80211_regdom, charp, 0444);
+module_param(ieee80211_regdom, charp, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain code");
 
 static void reg_free_request(struct regulatory_request *request)
-- 
2.9.2
