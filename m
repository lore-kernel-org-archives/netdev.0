From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1111/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:28 +0800
Message-ID: <20160802121728.24195-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
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
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 0a5a255..3a4321f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -66,7 +66,7 @@
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
 static bool log_ecn_error = true;
-module_param(log_ecn_error, bool, 0644);
+module_param(log_ecn_error, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 static int ipip6_tunnel_init(struct net_device *dev);
-- 
2.9.2
