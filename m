From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1120/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:14 +0800
Message-ID: <20160802121814.24791-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28881 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965696AbcHBM5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index db2312e..4001bd2 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1678,7 +1678,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
-		  &nf_conntrack_htable_size, 0600);
+		  &nf_conntrack_htable_size, S_IRUSR | S_IWUSR);
 
 void nf_ct_untracked_status_or(unsigned long bits)
 {
-- 
2.9.2
