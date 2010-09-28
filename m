From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] de2104x: remove experimental status
Date: Tue, 28 Sep 2010 20:46:17 +0200
Message-ID: <201009282046.21279.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:52106 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757797Ab0I1Sqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 14:46:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should be ready after 8 years...remove the experimental dependency.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-/drivers/net/tulip/Kconfig	2010-08-29 17:36:04.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/tulip/Kconfig	2010-09-28 19:49:46.000000000 +0200
@@ -11,8 +11,8 @@ menuconfig NET_TULIP
 if NET_TULIP
 
 config DE2104X
-	tristate "Early DECchip Tulip (dc2104x) PCI support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
+	tristate "Early DECchip Tulip (dc2104x) PCI support"
+	depends on PCI
 	select CRC32
 	---help---
 	  This driver is developed for the SMC EtherPower series Ethernet


-- 
Ondrej Zary
