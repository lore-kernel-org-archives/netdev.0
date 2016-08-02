From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0788/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:46:31 +0800
Message-ID: <20160802114631.2357-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, johannes.berg@intel.com,
	chuansheng.liu@intel.com, baolex.ni@intel.com
To: kvalo@codeaurora.org, luciano.coelho@intel.com,
	linuxwifi@intel.com, m.chehab@samsung.com, pawel@osciak.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8930 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934745AbcHBMYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:24:52 -0400
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
 drivers/net/wireless/marvell/libertas_tf/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas_tf/main.c b/drivers/net/wireless/marvell/libertas_tf/main.c
index 0bf8916..d0a1abb 100644
--- a/drivers/net/wireless/marvell/libertas_tf/main.c
+++ b/drivers/net/wireless/marvell/libertas_tf/main.c
@@ -25,7 +25,7 @@
 /* Module parameters */
 unsigned int lbtf_debug;
 EXPORT_SYMBOL_GPL(lbtf_debug);
-module_param_named(libertas_tf_debug, lbtf_debug, int, 0644);
+module_param_named(libertas_tf_debug, lbtf_debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 static const char lbtf_driver_version[] = "THINFIRM-USB8388-" DRIVER_RELEASE_VERSION
 #ifdef DEBUG
-- 
2.9.2
