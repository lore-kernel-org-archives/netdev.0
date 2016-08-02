From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1101/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:16:43 +0800
Message-ID: <20160802121643.23532-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9764 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965700AbcHBM4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:56:40 -0400
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
 net/ipv4/tcp_bic.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 36087bc..58c27d1 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -32,17 +32,17 @@ static int beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
 static int initial_ssthresh;
 static int smooth_part = 20;
 
-module_param(fast_convergence, int, 0644);
+module_param(fast_convergence, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fast_convergence, "turn on/off fast convergence");
-module_param(max_increment, int, 0644);
+module_param(max_increment, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_increment, "Limit on increment allowed during binary search");
-module_param(low_window, int, 0644);
+module_param(low_window, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(low_window, "lower bound on congestion window (for TCP friendliness)");
-module_param(beta, int, 0644);
+module_param(beta, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(beta, "beta for multiplicative increase");
-module_param(initial_ssthresh, int, 0644);
+module_param(initial_ssthresh, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(initial_ssthresh, "initial value of slow start threshold");
-module_param(smooth_part, int, 0644);
+module_param(smooth_part, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(smooth_part, "log(B/(B*Smin))/log(B/(B-1))+B, # of RTT from Wmax-B to Wmax");
 
 /* BIC TCP Parameters */
-- 
2.9.2
