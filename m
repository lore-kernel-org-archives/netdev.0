From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/4] r6040: no longer mark r6040 as being experimental
Date: Fri, 9 Jan 2009 02:04:50 +0100
Message-ID: <200901090204.50478.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:32932 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759833AbZAIBEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 20:04:54 -0500
Received: by mail-bw0-f21.google.com with SMTP id 14so28273359bwz.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 17:04:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/4] r6040: no longer mark r6040 as being experimental

We do not depend on EXPERIMENTAL and the driver is
not experimental, so remove this warning.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 11f143f..65e922c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1598,7 +1598,7 @@ config 8139_OLD_RX_RESET
 	  old RX-reset behavior.  If unsure, say N.
 
 config R6040
-	tristate "RDC R6040 Fast Ethernet Adapter support (EXPERIMENTAL)"
+	tristate "RDC R6040 Fast Ethernet Adapter support"
 	depends on NET_PCI && PCI
 	select CRC32
 	select MII
