From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1117/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:18:00 +0800
Message-ID: <20160802121800.24593-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aryabinin@virtuozzo.com
To: wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47480 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965710AbcHBM5R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:17 -0400
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
 net/netfilter/ipvs/ip_vs_ftp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index d30c327..1c989ae 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -54,7 +54,7 @@
  */
 static unsigned int ports_count = 1;
 static unsigned short ports[IP_VS_APP_MAX_PORTS] = {21, 0};
-module_param_array(ports, ushort, &ports_count, 0444);
+module_param_array(ports, ushort, &ports_count, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ports, "Ports to monitor for FTP control commands");
 
 
-- 
2.9.2
