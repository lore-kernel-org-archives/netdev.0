From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0787/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:46:25 +0800
Message-ID: <20160802114625.2222-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: kvalo@codeaurora.org, luciano.coelho@intel.com,
	linuxwifi@intel.com, m.chehab@samsung.com, pawel@osciak.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41648 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934697AbcHBMYu (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/wireless/marvell/libertas_tf/if_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/libertas_tf/if_usb.c b/drivers/net/wireless/marvell/libertas_tf/if_usb.c
index 799a2ef..4504f2c 100644
--- a/drivers/net/wireless/marvell/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/marvell/libertas_tf/if_usb.c
@@ -27,7 +27,7 @@
 #define MESSAGE_HEADER_LEN	4
 
 static char *lbtf_fw_name = "lbtf_usb.bin";
-module_param_named(fw_name, lbtf_fw_name, charp, 0644);
+module_param_named(fw_name, lbtf_fw_name, charp, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 MODULE_FIRMWARE("lbtf_usb.bin");
 
-- 
2.9.2
