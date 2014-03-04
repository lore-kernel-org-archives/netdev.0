From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 2/2] ieee802154: fix whitespace issues in Kconfig
Date: Tue,  4 Mar 2014 19:01:18 +0100
Message-ID: <1393956078-6950-3-git-send-email-alex.aring@gmail.com>
References: <1393956078-6950-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:64481 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764AbaCDSBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:01:31 -0500
Received: by mail-ea0-f180.google.com with SMTP id m10so522923eaj.39
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 10:01:30 -0800 (PST)
In-Reply-To: <1393956078-6950-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes some whitespace issues in Kconfig files of IEEE
802.15.4 subsytem.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/Kconfig | 26 +++++++++++++-------------
 net/ieee802154/Kconfig         |  2 +-
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
index 16e9331..9aa06ec 100644
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
+	depends on IEEE802154_DRIVERS && MAC802154
 	tristate "AT86RF230/231/212 transceiver driver"
-        depends on SPI
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
