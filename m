From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH] net: qualcomm: Fix dependancy
Date: Tue, 11 Nov 2014 21:08:30 +0000
Message-ID: <1415740110-19518-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:49889 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbaKKVIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:08:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unfortunately the patch for adding QCA7000 driver contains an old
version of Kconfig, which requires OF_GPIO. This is not necessary
anymore and need to be replaced with OF.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/qualcomm/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index f3a4714..247a287 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_QUALCOMM
 	bool "Qualcomm devices"
 	default y
-	depends on SPI_MASTER && OF_GPIO
+	depends on SPI_MASTER && OF
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -20,7 +20,7 @@ if NET_VENDOR_QUALCOMM
 
 config QCA7000
 	tristate "Qualcomm Atheros QCA7000 support"
-	depends on SPI_MASTER && OF_GPIO
+	depends on SPI_MASTER && OF
 	---help---
 	  This SPI protocol driver supports the Qualcomm Atheros QCA7000.
 
-- 
1.7.9.5
