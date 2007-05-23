From: Jan Altenberg <jan.altenberg@linutronix.de>
Subject: [PATCH] Add select PHYLIB to the UCC_GETH Kconfig option
Date: Wed, 23 May 2007 15:23:22 +0200
Message-ID: <1179926613.3839.47.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kim.phillips@freescale.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:48599 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755664AbXEWNXi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 09:23:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ucc_geth has been migrated to use the common phylib code. So lets add a
'select PHYLIB' to the UCC_GETH Kconfig entry.

Signed-off-by: Jan Altenberg <jan.altenberg@linutronix.de>

---
 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/drivers/net/Kconfig
===================================================================
--- linux-2.6.orig/drivers/net/Kconfig
+++ linux-2.6/drivers/net/Kconfig
@@ -2280,6 +2280,7 @@ config GFAR_NAPI
 config UCC_GETH
 	tristate "Freescale QE Gigabit Ethernet"
 	depends on QUICC_ENGINE
+	select PHYLIB
 	select UCC_FAST
 	help
 	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,


