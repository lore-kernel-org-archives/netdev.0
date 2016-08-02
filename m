From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1115/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:49 +0800
Message-ID: <20160802121749.24461-1-baolex.ni@intel.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	johunt@akamai.com, ebiederm@xmission.com, vpai@akamai.com,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	aryabinin@virtuozzo.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
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
 net/netfilter/ipset/ip_set_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index a748b0c..b6c060d3 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -48,7 +48,7 @@ static inline struct ip_set_net *ip_set_pernet(struct net *net)
 
 static unsigned int max_sets;
 
-module_param(max_sets, int, 0600);
+module_param(max_sets, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(max_sets, "maximal number of sets");
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
-- 
2.9.2
