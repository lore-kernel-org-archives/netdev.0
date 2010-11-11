From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 10/12] vxge: update Kconfig
Date: Thu, 11 Nov 2010 08:26:02 -0600
Message-ID: <1289485564-8822-11-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64088 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787Ab0KKO12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 09:27:28 -0500
Received: by mail-gx0-f174.google.com with SMTP id 23so1162812gxk.19
        for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 06:27:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Kconfig to reflect Exar's purchase of Neterion (formerly S2IO).

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/Kconfig |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f6668cd..fa62a63 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2772,29 +2772,38 @@ config IXGB
 	  will be called ixgb.
 
 config S2IO
-	tristate "S2IO 10Gbe XFrame NIC"
+	tristate "Exar Xframe 10Gb Ethernet Adapter"
 	depends on PCI
 	---help---
-	  This driver supports the 10Gbe XFrame NIC of S2IO. 
+	  This driver supports Exar Corp's Xframe Series 10Gb Ethernet Adapters.
+
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/s2io.txt>.
 
+	  To compile this driver as a module, choose M here. The module
+	  will be called s2io.
+
 config VXGE
-	tristate "Neterion X3100 Series 10GbE PCIe Server Adapter"
+	tristate "Exar X3100 Series 10GbE PCIe Server Adapter"
 	depends on PCI && INET
 	---help---
-	  This driver supports Neterion Inc's X3100 Series 10 GbE PCIe
+	  This driver supports Exar Corp's X3100 Series 10 GbE PCIe
 	  I/O Virtualized Server Adapter.
+
 	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/vxge.txt>.
 
+	  To compile this driver as a module, choose M here. The module
+	  will be called vxge.
+
 config VXGE_DEBUG_TRACE_ALL
 	bool "Enabling All Debug trace statments in driver"
 	default n
 	depends on VXGE
 	---help---
 	  Say Y here if you want to enabling all the debug trace statements in
-	  driver. By  default only few debug trace statements are enabled.
+	  the vxge driver. By default only few debug trace statements are
+	  enabled.
 
 config MYRI10GE
 	tristate "Myricom Myri-10G Ethernet support"
-- 
1.7.0.4

