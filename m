From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1105/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:01 +0800
Message-ID: <20160802121701.23799-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43406 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966539AbcHBNR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 09:17:56 -0400
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
 net/ipv4/tcp_htcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 4a4d8e7..2596861 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -15,11 +15,11 @@
 #define BETA_MAX	102	/* 0.8 with shift << 7 */
 
 static int use_rtt_scaling __read_mostly = 1;
-module_param(use_rtt_scaling, int, 0644);
+module_param(use_rtt_scaling, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_rtt_scaling, "turn on/off RTT scaling");
 
 static int use_bandwidth_switch __read_mostly = 1;
-module_param(use_bandwidth_switch, int, 0644);
+module_param(use_bandwidth_switch, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_bandwidth_switch, "turn on/off bandwidth switcher");
 
 struct htcp {
-- 
2.9.2
