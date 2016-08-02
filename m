From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1126/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:43 +0800
Message-ID: <20160802121843.25188-1-baolex.ni@intel.com>
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
 net/netfilter/nf_conntrack_sane.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_conntrack_sane.c
index 3fcbaab..4b39f41 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -42,7 +42,7 @@ static DEFINE_SPINLOCK(nf_sane_lock);
 #define MAX_PORTS 8
 static u_int16_t ports[MAX_PORTS];
 static unsigned int ports_c;
-module_param_array(ports, ushort, &ports_c, 0400);
+module_param_array(ports, ushort, &ports_c, S_IRUSR);
 
 struct sane_request {
 	__be32 RPC_code;
-- 
2.9.2
