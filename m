From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] NET_VENDOR_TI: make available for am33xx as well
Date: Wed, 24 Oct 2012 00:11:55 +0200
Message-ID: <1351030315-4156-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:62666 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932796Ab2JWWMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 18:12:03 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so4154831wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 15:12:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The cpsw/davinci mdio ip cores are present on am33xx, so make NET_VENDOR_TI
visible for it as well.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/ethernet/ti/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
index b26cbda..2c41894 100644
--- a/drivers/net/ethernet/ti/Kconfig
+++ b/drivers/net/ethernet/ti/Kconfig
@@ -5,7 +5,7 @@
 config NET_VENDOR_TI
 	bool "Texas Instruments (TI) devices"
 	default y
-	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3))
+	depends on PCI || EISA || AR7 || (ARM && (ARCH_DAVINCI || ARCH_OMAP3 || SOC_AM33XX))
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
-- 
1.7.10.4
