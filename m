From: Nathan Williams <nathan@traverse.com.au>
Subject: [PATCH] atm: select FW_LOADER in Kconfig for solos-pci
Date: Sun, 16 May 2010 23:12:36 +1000 (EST)
Message-ID: <alpine.DEB.1.10.1005162220500.15165@debian>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.virginbroadband.com.au ([123.200.191.11]:51939 "EHLO
	smtp.virginbroadband.com.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074Ab0EPNVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 09:21:41 -0400
Received: from [121.91.118.133] (unknown [121.91.118.133])
	by smtp.virginbroadband.com.au (Postfix) with ESMTP id B7A9D65A5056
	for <netdev@vger.kernel.org>; Sun, 16 May 2010 23:12:49 +1000 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

solos-pci uses request_firmware() for firmware upgrades

Signed-off-by: Nathan Williams <nathan@traverse.com.au>

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index 191b85e..f1a0a00 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -394,6 +394,7 @@ config ATM_HE_USE_SUNI
 config ATM_SOLOS
 	tristate "Solos ADSL2+ PCI Multiport card driver"
 	depends on PCI
+	select FW_LOADER
 	help
 	  Support for the Solos multiport ADSL2+ card.

