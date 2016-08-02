From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1128/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:53 +0800
Message-ID: <20160802121853.25320-1-baolex.ni@intel.com>
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
 net/netfilter/nf_conntrack_tftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_tftp.c b/net/netfilter/nf_conntrack_tftp.c
index 2e65b543..90ebc0f 100644
--- a/net/netfilter/nf_conntrack_tftp.c
+++ b/net/netfilter/nf_conntrack_tftp.c
@@ -29,7 +29,7 @@ MODULE_ALIAS_NFCT_HELPER("tftp");
 #define MAX_PORTS 8
 static unsigned short ports[MAX_PORTS];
 static unsigned int ports_c;
-module_param_array(ports, ushort, &ports_c, 0400);
+module_param_array(ports, ushort, &ports_c, S_IRUSR);
 MODULE_PARM_DESC(ports, "Port numbers of TFTP servers");
 
 unsigned int (*nf_nat_tftp_hook)(struct sk_buff *skb,
-- 
2.9.2
