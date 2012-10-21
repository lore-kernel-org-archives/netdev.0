From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 1/5] net/cadence: get rid of HAVE_NET_MACB
Date: Sun, 21 Oct 2012 16:23:08 +0200
Message-ID: <1350829392-3812-2-git-send-email-manabian@gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:45876 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab2JUOXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 10:23:35 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so1120285lag.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 07:23:34 -0700 (PDT)
In-Reply-To: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

macb is a platform driver and there is nothing that prevents
this driver from being built on non-ARM/AVR32 platforms.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/Kconfig | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 57f78abe..5d1ea30 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -2,13 +2,9 @@
 # Atmel device configuration
 #
 
-config HAVE_NET_MACB
-	bool
-
 config NET_CADENCE
 	bool "Cadence devices"
 	default y
-	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
@@ -34,7 +30,6 @@ config ARM_AT91_ETHER
 
 config MACB
 	tristate "Cadence MACB/GEM support"
-	depends on HAVE_NET_MACB
 	select PHYLIB
 	---help---
 	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
-- 
1.7.12.4
