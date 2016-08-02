From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1113/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:38 +0800
Message-ID: <20160802121738.24327-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aarcange@redhat.com, aryabinin@virtuozzo.com
To: johannes@sipsolutions.net, davem@davemloft.net, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42818 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965631AbcHBM5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:16 -0400
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
 net/mac80211/rate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 206698b..43bd119 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -25,7 +25,7 @@ static LIST_HEAD(rate_ctrl_algs);
 static DEFINE_MUTEX(rate_ctrl_mutex);
 
 static char *ieee80211_default_rc_algo = CONFIG_MAC80211_RC_DEFAULT;
-module_param(ieee80211_default_rc_algo, charp, 0644);
+module_param(ieee80211_default_rc_algo, charp, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ieee80211_default_rc_algo,
 		 "Default rate control algorithm for mac80211 to use");
 
-- 
2.9.2
