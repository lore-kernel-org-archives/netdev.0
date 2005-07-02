From: Adrian Bunk <bunk@stusta.de>
Subject: [RFC: -mm patch] remove unused IPW2100_PROMISC option
Date: Sat, 2 Jul 2005 23:52:30 +0200
Message-ID: <20050702215230.GF5346@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261295AbVGBV4j@vger.kernel.org>
To: ipw2100-admin@linux.intel.com, jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes a completely unsed option.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc1-mm1-full/drivers/net/wireless/Kconfig.old	2005-07-02 22:41:09.000000000 +0200
+++ linux-2.6.13-rc1-mm1-full/drivers/net/wireless/Kconfig	2005-07-02 22:41:17.000000000 +0200
@@ -164,15 +164,6 @@
           say M here and read <file:Documentation/modules.txt>.  The module
           will be called ipw2100.ko.
 	
-config IPW2100_PROMISC
-        bool "Enable promiscuous mode"
-        depends on IPW2100
-        ---help---
-	  Enables promiscuous/monitor mode support for the ipw2100 driver.
-	  With this feature compiled into the driver, you can switch to 
-	  promiscuous mode via the Wireless Tool's Monitor mode.  While in this
-	  mode, no packets can be sent.
-
 config IPW_DEBUG
 	bool "Enable full debugging output in IPW2100 module."
 	depends on IPW2100
