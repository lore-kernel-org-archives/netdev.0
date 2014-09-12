From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH] net: rfkill: gpio: Enable module auto-loading for ACPI based switches
Date: Fri, 12 Sep 2014 20:50:42 +0200
Message-ID: <1410547842-50207-1-git-send-email-marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:58278 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaILSuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 14:50:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switches that are enumerated over ACPI require a MODULE_ALIAS to
allow auto-loading of the module.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/rfkill/rfkill-gpio.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 02a86a27fd84..35e659392209 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -180,3 +180,12 @@ module_platform_driver(rfkill_gpio_driver);
 MODULE_DESCRIPTION("gpio rfkill");
 MODULE_AUTHOR("NVIDIA");
 MODULE_LICENSE("GPL");
+
+#ifdef CONFIG_ACPI
+MODULE_ALIAS("acpi:BCM2E1A");
+MODULE_ALIAS("acpi:BCM2E39");
+MODULE_ALIAS("acpi:BCM2E3D");
+MODULE_ALIAS("acpi:BCM2E64");
+MODULE_ALIAS("acpi:BCM4752");
+MODULE_ALIAS("acpi:LNV4752");
+#endif
-- 
1.9.3
