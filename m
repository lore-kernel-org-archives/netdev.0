From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1107/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:17:10 +0800
Message-ID: <20160802121710.23931-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50779 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966377AbcHBNQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 09:16:47 -0400
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
 net/ipv4/tcp_vegas.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 4c4bac1..bf0979b 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -44,11 +44,11 @@ static int alpha = 2;
 static int beta  = 4;
 static int gamma = 1;
 
-module_param(alpha, int, 0644);
+module_param(alpha, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(alpha, "lower bound of packets in network");
-module_param(beta, int, 0644);
+module_param(beta, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(beta, "upper bound of packets in network");
-module_param(gamma, int, 0644);
+module_param(gamma, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(gamma, "limit on increase (scale by 2)");
 
 /* There are several situations when we must "re-start" Vegas:
-- 
2.9.2
