From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1125/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:37 +0800
Message-ID: <20160802121837.25122-1-baolex.ni@intel.com>
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
 net/netfilter/nf_conntrack_irc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntrack_irc.c
index f97ac61..53fe56d 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -48,12 +48,12 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ip_conntrack_irc");
 MODULE_ALIAS_NFCT_HELPER("irc");
 
-module_param_array(ports, ushort, &ports_c, 0400);
+module_param_array(ports, ushort, &ports_c, S_IRUSR);
 MODULE_PARM_DESC(ports, "port numbers of IRC servers");
-module_param(max_dcc_channels, uint, 0400);
+module_param(max_dcc_channels, uint, S_IRUSR);
 MODULE_PARM_DESC(max_dcc_channels, "max number of expected DCC channels per "
 				   "IRC session");
-module_param(dcc_timeout, uint, 0400);
+module_param(dcc_timeout, uint, S_IRUSR);
 MODULE_PARM_DESC(dcc_timeout, "timeout on for unestablished DCC channels");
 
 static const char *const dccprotos[] = {
-- 
2.9.2
