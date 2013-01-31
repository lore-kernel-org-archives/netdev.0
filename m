From: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
Subject: [PATCH] net/cadence: don't build by default
Date: Thu, 31 Jan 2013 19:26:55 +0100
Message-ID: <1359656815-27919-1-git-send-email-riccardo.magliocchetti@gmail.com>
Cc: netdev@vger.kernel.org,
	Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:33276 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3AaS1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 13:27:32 -0500
Received: by mail-ea0-f180.google.com with SMTP id c1so1337214eaa.11
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 10:27:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to build net/cadence driver by default.

Signed-off-by: Riccardo Magliocchetti <riccardo.magliocchetti@gmail.com>
---
 drivers/net/ethernet/cadence/Kconfig |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index ceb0de0..8901951 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -5,13 +5,12 @@
 config NET_CADENCE
 	bool "Cadence devices"
 	depends on HAS_IOMEM
-	default y
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
 	  available from <http://www.tldp.org/docs.html#howto>.
 
-	  If unsure, say Y.
+	  If unsure, say N.
 
 	  Note that the answer to this question doesn't directly affect the
 	  kernel: saying N will just cause the configurator to skip all
-- 
1.7.10.4
