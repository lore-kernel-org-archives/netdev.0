From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1092/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:15:52 +0800
Message-ID: <20160802121552.22930-1-baolex.ni@intel.com>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aduyck@mirantis.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: gerrit@erg.abdn.ac.uk, davem@davemloft.net,
	johan.hedberg@gmail.com, jiangshanlai@gmail.com,
	m.chehab@samsung.com, gregkh@linuxfoundation.org,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:45944 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965466AbcHBMxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:53:34 -0400
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
 net/dccp/ccids/ccid2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index f053198..6d301ee 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -175,7 +175,7 @@ out:
  *	Congestion window validation (RFC 2861).
  */
 static bool ccid2_do_cwv = true;
-module_param(ccid2_do_cwv, bool, 0644);
+module_param(ccid2_do_cwv, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ccid2_do_cwv, "Perform RFC2861 Congestion Window Validation");
 
 /**
@@ -779,6 +779,6 @@ struct ccid_operations ccid2_ops = {
 };
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-module_param(ccid2_debug, bool, 0644);
+module_param(ccid2_debug, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ccid2_debug, "Enable CCID-2 debug messages");
 #endif
-- 
2.9.2
