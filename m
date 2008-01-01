From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] ip1000: menu location change
Date: Tue, 1 Jan 2008 09:27:58 -0800
Message-ID: <20080101092758.59bd5665@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42077 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754335AbYAAR33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2008 12:29:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the ip1000 driver into the expected place for gigabit cards
in the configuration menu structure. It should be under the gigabit
cards, not at the top level.

Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

--- a/drivers/net/Kconfig	2007-12-26 20:17:31.000000000 -0800
+++ b/drivers/net/Kconfig	2007-12-26 20:18:36.000000000 -0800
@@ -166,16 +166,6 @@ config NET_SB1000
 
 	  If you don't have this card, of course say N.
 
-config IP1000
-	tristate "IP1000 Gigabit Ethernet support"
-	depends on PCI && EXPERIMENTAL
-	select MII
-	---help---
-	  This driver supports IP1000 gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called ipg.  This is recommended.
-
 source "drivers/net/arcnet/Kconfig"
 
 source "drivers/net/phy/Kconfig"
@@ -2004,6 +1994,16 @@ config E1000E
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
+config IP1000
+	tristate "IP1000 Gigabit Ethernet support"
+	depends on PCI && EXPERIMENTAL
+	select MII
+	---help---
+	  This driver supports IP1000 gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called ipg.  This is recommended.
+
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
