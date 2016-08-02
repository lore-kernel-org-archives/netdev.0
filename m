From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1129/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:58 +0800
Message-ID: <20160802121858.25386-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2718 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965745AbcHBM5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 net/netfilter/nf_conntrack_timestamp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index 7a394df..c711c6a 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -17,7 +17,7 @@
 
 static bool nf_ct_tstamp __read_mostly;
 
-module_param_named(tstamp, nf_ct_tstamp, bool, 0644);
+module_param_named(tstamp, nf_ct_tstamp, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(tstamp, "Enable connection tracking flow timestamping.");
 
 #ifdef CONFIG_SYSCTL
-- 
2.9.2
