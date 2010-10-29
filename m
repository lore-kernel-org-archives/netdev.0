From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 10/11] vxge: update Kconfig
Date: Thu, 28 Oct 2010 21:19:45 -0500
Message-ID: <1288318786-12319-10-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38349 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760227Ab0J2CU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:20:26 -0400
Received: by mail-yw0-f46.google.com with SMTP id 9so1727254ywk.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:20:25 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update Kconfig to reflect Exar's purchase of Neterion (formerly S2IO).

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/Kconfig |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 77c1fab..123a11e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2750,29 +2750,38 @@ config IXGB
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

