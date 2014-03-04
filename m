From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH 1/2] at86rf230: add help and 212 to Kconfig menu entry
Date: Tue,  4 Mar 2014 11:22:29 +0100
Message-ID: <1393928550-31949-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:39054 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756666AbaCDKXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:23:05 -0500
Received: by mail-ee0-f52.google.com with SMTP id e49so1341462eek.25
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 02:23:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit e035b8addc544c2b4de2f8b0326ba7939abd9541 we support at86rf212
aswell.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/Kconfig | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 08ae465..807ad1f 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -32,8 +32,14 @@ config IEEE802154_FAKELB
 
 config IEEE802154_AT86RF230
         depends on IEEE802154_DRIVERS && MAC802154
-        tristate "AT86RF230/231 transceiver driver"
+        tristate "AT86RF230/231/212 transceiver driver"
         depends on SPI
+	---help---
+	  Say Y here to enable the at86rf230/231/212 SPI 802.15.4 wireless
+	  controller.
+
+	  This driver can also be built as a module. To do so, say M here.
+	  the module will be called 'at86rf230'.
 
 config IEEE802154_MRF24J40
        tristate "Microchip MRF24J40 transceiver driver"
-- 
1.9.0
