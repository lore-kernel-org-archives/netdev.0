From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH 2/2] ieee802154: fix whitespace issues in Kconfig
Date: Tue,  4 Mar 2014 11:22:30 +0100
Message-ID: <1393928550-31949-2-git-send-email-alex.aring@gmail.com>
References: <1393928550-31949-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:50078 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756721AbaCDKXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:23:06 -0500
Received: by mail-ea0-f175.google.com with SMTP id d10so240811eaj.6
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 02:23:04 -0800 (PST)
In-Reply-To: <1393928550-31949-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes some whitespace issues in Kconfig files of IEEE
802.15.4 subsytem.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/Kconfig | 28 ++++++++++++++--------------
 net/ieee802154/Kconfig         |  2 +-
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 807ad1f..9aa06ec 100644
--- a/drivers/net/ieee802154/Kconfig
+++ b/drivers/net/ieee802154/Kconfig
@@ -15,9 +15,9 @@ config IEEE802154_FAKEHARD
 	depends on  IEEE802154_DRIVERS
 	---help---
 	  Say Y here to enable the fake driver that serves as an example
-          of HardMAC device driver.
+	  of HardMAC device driver.
 
-          This driver can also be built as a module. To do so say M here.
+	  This driver can also be built as a module. To do so say M here.
 	  The module will be called 'fakehard'.
 
 config IEEE802154_FAKELB
@@ -31,9 +31,9 @@ config IEEE802154_FAKELB
 	  The module will be called 'fakelb'.
 
 config IEEE802154_AT86RF230
-        depends on IEEE802154_DRIVERS && MAC802154
-        tristate "AT86RF230/231/212 transceiver driver"
-        depends on SPI
+	depends on IEEE802154_DRIVERS && MAC802154
+	tristate "AT86RF230/231/212 transceiver driver"
+	depends on SPI
 	---help---
 	  Say Y here to enable the at86rf230/231/212 SPI 802.15.4 wireless
 	  controller.
@@ -42,12 +42,12 @@ config IEEE802154_AT86RF230
 	  the module will be called 'at86rf230'.
 
 config IEEE802154_MRF24J40
-       tristate "Microchip MRF24J40 transceiver driver"
-       depends on IEEE802154_DRIVERS && MAC802154
-       depends on SPI
-       ---help---
-         Say Y here to enable the MRF24J20 SPI 802.15.4 wireless
-         controller.
-
-         This driver can also be built as a module. To do so, say M here.
-         the module will be called 'mrf24j40'.
+	tristate "Microchip MRF24J40 transceiver driver"
+	depends on IEEE802154_DRIVERS && MAC802154
+	depends on SPI
+	---help---
+	  Say Y here to enable the MRF24J20 SPI 802.15.4 wireless
+	  controller.
+
+	  This driver can also be built as a module. To do so, say M here.
+	  the module will be called 'mrf24j40'.
diff --git a/net/ieee802154/Kconfig b/net/ieee802154/Kconfig
index 9c9879d..8af1330 100644
--- a/net/ieee802154/Kconfig
+++ b/net/ieee802154/Kconfig
@@ -15,7 +15,7 @@ config IEEE802154_6LOWPAN
 	depends on IEEE802154 && IPV6
 	select 6LOWPAN_IPHC
 	---help---
-	IPv6 compression over IEEE 802.15.4.
+	  IPv6 compression over IEEE 802.15.4.
 
 config 6LOWPAN_IPHC
 	tristate
-- 
1.9.0
