From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0792/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:46:50 +0800
Message-ID: <20160802114650.2621-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: Jes.Sorensen@redhat.com, kvalo@codeaurora.org, linuxwifi@intel.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:23660 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934779AbcHBMYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:24:50 -0400
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
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
index 9f6dbb4..8800df2 100644
--- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
+++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
@@ -58,9 +58,9 @@ MODULE_FIRMWARE("rtlwifi/rtl8192eu_nic.bin");
 MODULE_FIRMWARE("rtlwifi/rtl8723bu_nic.bin");
 MODULE_FIRMWARE("rtlwifi/rtl8723bu_bt.bin");
 
-module_param_named(debug, rtl8xxxu_debug, int, 0600);
+module_param_named(debug, rtl8xxxu_debug, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(debug, "Set debug mask");
-module_param_named(ht40_2g, rtl8xxxu_ht40_2g, bool, 0600);
+module_param_named(ht40_2g, rtl8xxxu_ht40_2g, bool, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(ht40_2g, "Enable HT40 support on the 2.4GHz band");
 
 #define USB_VENDOR_ID_REALTEK		0x0bda
-- 
2.9.2
