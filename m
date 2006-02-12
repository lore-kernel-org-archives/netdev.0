From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: 2.6 patch] CONFIG_FORCEDETH updates
Date: Sun, 12 Feb 2006 18:52:02 +0100
Message-ID: <20060212175202.GK30922@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751347AbWBLRwF@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following possible updates:
- let FORCEDETH no longer depend on EXPERIMENTAL
- remove the "Reverse Engineered" from the option text:
  for the user it's important which hardware the driver supports, not
  how it was developed


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc2-mm1-full/drivers/net/Kconfig.old	2006-02-12 02:23:31.000000000 +0100
+++ linux-2.6.16-rc2-mm1-full/drivers/net/Kconfig	2006-02-12 02:24:04.000000000 +0100
@@ -1370,10 +1370,10 @@
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
 	  called b44.
 
 config FORCEDETH
-	tristate "Reverse Engineered nForce Ethernet support (EXPERIMENTAL)"
-	depends on NET_PCI && PCI && EXPERIMENTAL
+	tristate "nForce Ethernet support"
+	depends on NET_PCI && PCI
 	help
 	  If you have a network (Ethernet) controller of this type, say Y and
 	  read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
