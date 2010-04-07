From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/7] au1000-eth: allow driver to be compiled as a module
Date: Wed, 7 Apr 2010 10:08:53 +0200
Message-ID: <201004071008.54042.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:19764 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab0DGIKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 04:10:02 -0400
Received: by ey-out-2122.google.com with SMTP id 9so268278eyd.5
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 01:10:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the au1000-eth driver to be compiled as a module.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 20e2dec..ac2e364 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -483,7 +483,7 @@ config XTENSA_XT2000_SONIC
 	  This is the driver for the onboard card of the Xtensa XT2000 board.
 
 config MIPS_AU1X00_ENET
-	bool "MIPS AU1000 Ethernet support"
+	tristate "MIPS AU1000 Ethernet support"
 	depends on SOC_AU1X00
 	select PHYLIB
 	select CRC32
