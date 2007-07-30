From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 2.6.23-rc1] PPPOL2TP: Add CONFIG_INET Kconfig dependency
Date: Mon, 30 Jul 2007 13:05:39 +0100
Message-ID: <200707301205.l6UC5dmR026629@quickie.katalix.com>
Cc: toralf.foerster@gmx.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:52498 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759587AbXG3MGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 08:06:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPPOL2TP]: Add CONFIG_INET Kconfig dependency.

PPPOL2TP uses UDP so it obviously depends on CONFIG_INET. 

Signed-off-by: James Chapman <jchapman@katalix.com>

--- 
Toralf Foerster reported that make rndconfig failed in 2.6.23-rc1
when selecting CONFIG_PPPOL2TP without CONFIG_INET.

Index: linux-2.6.23-rc1/drivers/net/Kconfig
===================================================================
--- linux-2.6.23-rc1.orig/drivers/net/Kconfig
+++ linux-2.6.23-rc1/drivers/net/Kconfig
@@ -2851,7 +2851,7 @@ config PPPOATM
 
 config PPPOL2TP
 	tristate "PPP over L2TP (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && PPP
+	depends on EXPERIMENTAL && PPP && INET
 	help
 	  Support for PPP-over-L2TP socket family. L2TP is a protocol
 	  used by ISPs and enterprises to tunnel PPP traffic over UDP
