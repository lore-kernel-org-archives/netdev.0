From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1124/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:33 +0800
Message-ID: <20160802121833.25055-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60769 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965845AbcHBM5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:23 -0400
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
 net/netfilter/nf_conntrack_helper.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 196cb39..8bf107d 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -39,7 +39,7 @@ EXPORT_SYMBOL_GPL(nf_ct_helper_hsize);
 static unsigned int nf_ct_helper_count __read_mostly;
 
 static bool nf_ct_auto_assign_helper __read_mostly = false;
-module_param_named(nf_conntrack_helper, nf_ct_auto_assign_helper, bool, 0644);
+module_param_named(nf_conntrack_helper, nf_ct_auto_assign_helper, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nf_conntrack_helper,
 		 "Enable automatic conntrack helper assignment (default 0)");
 
-- 
2.9.2
