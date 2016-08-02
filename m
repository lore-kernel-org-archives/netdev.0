From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0782/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:51 +0800
Message-ID: <20160802114551.1879-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, a@unstable.cc, fw@strlen.de,
	Jes.Sorensen@redhat.com, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: kvalo@codeaurora.org, luciano.coelho@intel.com,
	linuxwifi@intel.com, m.chehab@samsung.com, pawel@osciak.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:32693 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934689AbcHBM0j (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/wireless/intersil/orinoco/main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intersil/orinoco/main.c b/drivers/net/wireless/intersil/orinoco/main.c
index 7afe200..763fd1d 100644
--- a/drivers/net/wireless/intersil/orinoco/main.c
+++ b/drivers/net/wireless/intersil/orinoco/main.c
@@ -117,21 +117,21 @@ MODULE_LICENSE("Dual MPL/GPL");
 #ifdef ORINOCO_DEBUG
 int orinoco_debug = ORINOCO_DEBUG;
 EXPORT_SYMBOL(orinoco_debug);
-module_param(orinoco_debug, int, 0644);
+module_param(orinoco_debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(orinoco_debug, "Debug level");
 #endif
 
 static bool suppress_linkstatus; /* = 0 */
-module_param(suppress_linkstatus, bool, 0644);
+module_param(suppress_linkstatus, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
 
 static int ignore_disconnect; /* = 0 */
-module_param(ignore_disconnect, int, 0644);
+module_param(ignore_disconnect, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ignore_disconnect,
 		 "Don't report lost link to the network layer");
 
 int force_monitor; /* = 0 */
-module_param(force_monitor, int, 0644);
+module_param(force_monitor, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(force_monitor, "Allow monitor mode for all firmware versions");
 
 /********************************************************************/
-- 
2.9.2
