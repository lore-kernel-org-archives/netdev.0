From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1097/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:16:22 +0800
Message-ID: <20160802121622.23267-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aduyck@mirantis.com,
	aarcange@redhat.com, aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.chehab@samsung.com,
	gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
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
 net/ipv4/ip_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4d2025f..a69c2d2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -113,7 +113,7 @@
  */
 
 static bool log_ecn_error = true;
-module_param(log_ecn_error, bool, 0644);
+module_param(log_ecn_error, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
-- 
2.9.2
