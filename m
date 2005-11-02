From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] update S2IO help text
Date: Wed, 2 Nov 2005 02:53:12 +0100
Message-ID: <20051102015311.GE8009@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932160AbVKBBxU@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following updates to the S2IO help text:
- correct the patch to the README
- there is no information regarding compilation and installation of the
  driver in the README


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.14-rc5-mm1-modular-2.95/drivers/net/Kconfig.old	2005-11-02 02:46:21.000000000 +0100
+++ linux-2.6.14-rc5-mm1-modular-2.95/drivers/net/Kconfig	2005-11-02 02:50:13.000000000 +0100
@@ -2253,12 +2253,12 @@
 config S2IO
 	tristate "S2IO 10Gbe XFrame NIC"
 	depends on PCI
 	---help---
 	  This driver supports the 10Gbe XFrame NIC of S2IO. 
-	  For help regarding driver compilation, installation and 
-	  tuning please look into ~/drivers/net/s2io/README.txt.
+	  For help regarding driver tuning please look into
+	  <file:Documentation/networking/s2io.txt>.
 
 config S2IO_NAPI
 	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
 	depends on S2IO && EXPERIMENTAL
 	help
