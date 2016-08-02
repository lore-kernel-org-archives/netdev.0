From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1114/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:43 +0800
Message-ID: <20160802121743.24393-1-baolex.ni@intel.com>
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
 net/mac80211/rc80211_minstrel_ht.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/rc80211_minstrel_ht.c b/net/mac80211/rc80211_minstrel_ht.c
index 30fbabf..1b9d495 100644
--- a/net/mac80211/rc80211_minstrel_ht.c
+++ b/net/mac80211/rc80211_minstrel_ht.c
@@ -138,7 +138,7 @@
 
 #ifdef CONFIG_MAC80211_RC_MINSTREL_VHT
 static bool minstrel_vht_only = true;
-module_param(minstrel_vht_only, bool, 0644);
+module_param(minstrel_vht_only, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(minstrel_vht_only,
 		 "Use only VHT rates when VHT is supported by sta.");
 #endif
-- 
2.9.2
