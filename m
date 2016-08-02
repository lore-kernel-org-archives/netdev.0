From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0806/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:48:17 +0800
Message-ID: <20160802114817.3699-1-baolex.ni@intel.com>
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	jgross@suse.com, linuxwifi@intel.com, kvalo@codeaurora.org,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:39560 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934505AbcHBM0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:26:39 -0400
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
 drivers/net/xen-netfront.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 96ccd4e..70c86fa 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -58,7 +58,7 @@
 
 /* Module parameters */
 static unsigned int xennet_max_queues;
-module_param_named(max_queues, xennet_max_queues, uint, 0644);
+module_param_named(max_queues, xennet_max_queues, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_queues,
 		 "Maximum number of queues per virtual interface");
 
-- 
2.9.2
