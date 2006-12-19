From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/atm/Kconfig: remove dead ATM_TNETA1570 option
Date: Tue, 19 Dec 2006 05:13:00 +0100
Message-ID: <20061219041300.GD6993@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752434AbWLSENH@vger.kernel.org>
To: chas@cmf.nrl.navy.mil
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the unconverted ATM_TNETA1570 option that also lacks 
any code in the kernel.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.20-rc1-mm1/drivers/atm/Kconfig.old	2006-12-19 04:42:00.000000000 +0100
+++ linux-2.6.20-rc1-mm1/drivers/atm/Kconfig	2006-12-19 04:42:14.000000000 +0100
@@ -167,10 +167,6 @@
 	  Note that extended debugging may create certain race conditions
 	  itself. Enable this ONLY if you suspect problems with the driver.
 
-#   bool 'Rolfs TI TNETA1570' CONFIG_ATM_TNETA1570 y
-#   if [ "$CONFIG_ATM_TNETA1570" = "y" ]; then
-#      bool '  Enable extended debugging' CONFIG_ATM_TNETA1570_DEBUG n
-#   fi
 config ATM_NICSTAR
 	tristate "IDT 77201 (NICStAR) (ForeRunnerLE)"
 	depends on PCI && ATM && !64BIT
