From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH stable] r8169: Fix MII compilation error
Date: Fri, 14 Nov 2008 16:29:32 +0100
Message-ID: <200811141629.32474.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:57421 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751159AbYKNPdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 10:33:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a compilation error (undefined MII symbols), if
CONFIG_MII is not selected.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

---

This fix already is in Linus' tree and I think it's a -stable candidate,
as I just hit the bug while trying to compile 2.6.27.6.


Index: linux-2.6.27.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.27.6.orig/drivers/net/Kconfig	2008-11-14 17:34:43.000000000 +0100
+++ linux-2.6.27.6/drivers/net/Kconfig	2008-11-14 17:35:08.000000000 +0100
@@ -2046,6 +2046,7 @@
 	tristate "Realtek 8169 gigabit ethernet support"
 	depends on PCI
 	select CRC32
+	select MII
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
-- 
Greetings Michael.
