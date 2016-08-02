From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1106/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:05 +0800
Message-ID: <20160802121705.23865-1-baolex.ni@intel.com>
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
 net/ipv4/tcp_hybla.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index 083831e..8921ae2 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -26,7 +26,7 @@ struct hybla {
 
 /* Hybla reference round trip time (default= 1/40 sec = 25 ms), in ms */
 static int rtt0 = 25;
-module_param(rtt0, int, 0644);
+module_param(rtt0, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rtt0, "reference rout trip time (ms)");
 
 /* This is called to refresh values for hybla parameters */
-- 
2.9.2
