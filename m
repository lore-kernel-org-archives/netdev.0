From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1119/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:09 +0800
Message-ID: <20160802121809.24725-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
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
 net/netfilter/nf_conntrack_amanda.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_amanda.c b/net/netfilter/nf_conntrack_amanda.c
index 57a26cc..6311f98 100644
--- a/net/netfilter/nf_conntrack_amanda.c
+++ b/net/netfilter/nf_conntrack_amanda.c
@@ -34,9 +34,9 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ip_conntrack_amanda");
 MODULE_ALIAS_NFCT_HELPER("amanda");
 
-module_param(master_timeout, uint, 0600);
+module_param(master_timeout, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(master_timeout, "timeout for the master connection");
-module_param(ts_algo, charp, 0400);
+module_param(ts_algo, charp, S_IRUSR);
 MODULE_PARM_DESC(ts_algo, "textsearch algorithm to use (default kmp)");
 
 unsigned int (*nf_nat_amanda_hook)(struct sk_buff *skb,
-- 
2.9.2
