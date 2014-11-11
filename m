From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH V2] net: qualcomm: Fix dependency
Date: Tue, 11 Nov 2014 22:38:00 +0000
Message-ID: <1415745480-23692-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:58763 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbaKKWiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 17:38:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the dependency of the VENDOR entry and fixes
the QCA7000 one.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---

change in V2: remove dependency of the VENDOR entry suggested by
David Miller

 drivers/net/ethernet/qualcomm/Kconfig |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index f3a4714..9a49f42 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -5,7 +5,6 @@
 config NET_VENDOR_QUALCOMM
 	bool "Qualcomm devices"
 	default y
-	depends on SPI_MASTER && OF_GPIO
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -20,7 +19,7 @@ if NET_VENDOR_QUALCOMM
 
 config QCA7000
 	tristate "Qualcomm Atheros QCA7000 support"
-	depends on SPI_MASTER && OF_GPIO
+	depends on SPI_MASTER && OF
 	---help---
 	  This SPI protocol driver supports the Qualcomm Atheros QCA7000.
 
-- 
1.7.9.5
