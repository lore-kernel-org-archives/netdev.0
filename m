From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: not experimental
Date: Fri, 27 Oct 2006 10:22:10 -0700
Message-ID: <20061027102210.29739a22@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18405 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752298AbWJ0RXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 13:23:13 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sky2 driver is no longer in experimental state.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- sky2.orig/drivers/net/Kconfig	2006-10-27 10:16:44.000000000 -0700
+++ sky2/drivers/net/Kconfig	2006-10-27 10:20:20.000000000 -0700
@@ -2112,7 +2112,7 @@
 
 config SKY2
 	tristate "SysKonnect Yukon2 support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
+	depends on PCI
 	select CRC32
 	---help---
 	  This driver supports Gigabit Ethernet adapters based on the
@@ -2120,8 +2120,8 @@
 	  Marvell 88E8021/88E8022/88E8035/88E8036/88E8038/88E8050/88E8052/
 	  88E8053/88E8055/88E8061/88E8062, SysKonnect SK-9E21D/SK-9S21
 
-	  This driver does not support the original Yukon chipset: a seperate
-	  driver, skge, is provided for Yukon-based adapters.
+	  There is companion driver for the older Marvell Yukon and
+	  Genesis based adapters: skge.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called sky2.  This is recommended.
