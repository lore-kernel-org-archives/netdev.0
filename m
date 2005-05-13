From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] make MII no longer user visible
Date: Fri, 13 May 2005 05:52:57 +0200
Message-ID: <20050513035257.GC3603@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262228AbVEMDxD@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MII is a classical example of a helper option no user should ever see.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.12-rc4-mm1-full/drivers/net/Kconfig.old	2005-05-13 05:47:58.000000000 +0200
+++ linux-2.6.12-rc4-mm1-full/drivers/net/Kconfig	2005-05-13 05:48:27.000000000 +0200
@@ -165,12 +165,8 @@
 	  the questions about Ethernet network cards. If unsure, say N.
 
 config MII
-	tristate "Generic Media Independent Interface device support"
+	tristate
 	depends on NET_ETHERNET
-	help
-	  Most ethernet controllers have MII transceiver either as an external
-	  or internal device.  It is safe to say Y or M here even if your
-	  ethernet card lack MII.
 
 source "drivers/net/arm/Kconfig"
 
