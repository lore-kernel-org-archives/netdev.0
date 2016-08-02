From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0769/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:35 +0800
Message-ID: <20160802114435.929-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, khoroshilov@ispras.ru,
	johannes.berg@intel.com, chuansheng.liu@intel.com,
	baolex.ni@intel.com, pabeni@redhat.com
To: kvalo@codeaurora.org, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16778 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934744AbcHBMWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:22:36 -0400
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
 drivers/net/wireless/atmel/at76c50x-usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/atmel/at76c50x-usb.c b/drivers/net/wireless/atmel/at76c50x-usb.c
index 7c10804..5313e6f 100644
--- a/drivers/net/wireless/atmel/at76c50x-usb.c
+++ b/drivers/net/wireless/atmel/at76c50x-usb.c
@@ -2596,7 +2596,7 @@ static void __exit at76_mod_exit(void)
 	led_trigger_unregister_simple(ledtrig_tx);
 }
 
-module_param_named(debug, at76_debug, uint, 0600);
+module_param_named(debug, at76_debug, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(debug, "Debugging level");
 
 module_init(at76_mod_init);
-- 
2.9.2
