From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1104/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:16:57 +0800
Message-ID: <20160802121657.23730-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19406 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965862AbcHBM5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:41 -0400
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
 net/ipv4/tcp_dctcp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp_dctcp.c
index 7e538f7..9b15a63 100644
--- a/net/ipv4/tcp_dctcp.c
+++ b/net/ipv4/tcp_dctcp.c
@@ -59,15 +59,15 @@ struct dctcp {
 };
 
 static unsigned int dctcp_shift_g __read_mostly = 4; /* g = 1/2^4 */
-module_param(dctcp_shift_g, uint, 0644);
+module_param(dctcp_shift_g, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dctcp_shift_g, "parameter g for updating dctcp_alpha");
 
 static unsigned int dctcp_alpha_on_init __read_mostly = DCTCP_MAX_ALPHA;
-module_param(dctcp_alpha_on_init, uint, 0644);
+module_param(dctcp_alpha_on_init, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dctcp_alpha_on_init, "parameter for initial alpha value");
 
 static unsigned int dctcp_clamp_alpha_on_loss __read_mostly;
-module_param(dctcp_clamp_alpha_on_loss, uint, 0644);
+module_param(dctcp_clamp_alpha_on_loss, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dctcp_clamp_alpha_on_loss,
 		 "parameter for clamping alpha on loss");
 
-- 
2.9.2
