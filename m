From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH v2] net: rfkill: gpio: Enable module auto-loading for ACPI based switches
Date: Fri, 12 Sep 2014 21:49:28 +0200
Message-ID: <1410551368-37316-1-git-send-email-marcel@holtmann.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33009 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbaILTsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 15:48:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the ACPI based switches the MODULE_DEVICE_TABLE is missing to
export the entries for module auto-loading.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/rfkill/rfkill-gpio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 02a86a27fd84..5fa54dd78e25 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -163,6 +163,7 @@ static const struct acpi_device_id rfkill_acpi_match[] = {
 	{ "LNV4752", RFKILL_TYPE_GPS },
 	{ },
 };
+MODULE_DEVICE_TABLE(acpi, rfkill_acpi_match);
 #endif
 
 static struct platform_driver rfkill_gpio_driver = {
-- 
1.9.3
