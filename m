From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Drop ISA dependencies from IRDA drivers
Date: Thu, 15 Jul 2004 18:39:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m34qo96x8m.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: the_nihilant@autistici.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, irda-users@lists.sourceforge.net, jt@hpl.hp.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


http://bugme.osdl.org/show_bug.cgi?id=3077

Some IRDA chipsets currently don't work on x86-64, because
they're dependent on CONFIG_ISA and x86-64 doesn't set this.
CONFIG_ISA means real ISA slots, and I doubt these chips
come on real ISA cards, so I just removed the bogus 
dependency.

Please apply.

-Andi

diff -u linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig-o linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig
--- linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig-o	2004-07-12 06:09:05.000000000 +0200
+++ linux-2.6.8rc1-amd64/drivers/net/irda/Kconfig	2004-07-15 18:33:48.000000000 +0200
@@ -310,7 +310,7 @@
 
 config NSC_FIR
 	tristate "NSC PC87108/PC87338"
-	depends on IRDA && ISA
+	depends on IRDA
 	help
 	  Say Y here if you want to build support for the NSC PC87108 and
 	  PC87338 IrDA chipsets.  This driver supports SIR,
@@ -321,7 +321,7 @@
 
 config WINBOND_FIR
 	tristate "Winbond W83977AF (IR)"
-	depends on IRDA && ISA
+	depends on IRDA
 	help
 	  Say Y here if you want to build IrDA support for the Winbond
 	  W83977AF super-io chipset.  This driver should be used for the IrDA
@@ -347,7 +347,7 @@
 
 config SMC_IRCC_FIR
 	tristate "SMSC IrCC (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA
+	depends on EXPERIMENTAL && IRDA
 	help
 	  Say Y here if you want to build support for the SMC Infrared
 	  Communications Controller.  It is used in a wide variety of
@@ -357,7 +357,7 @@
 
 config ALI_FIR
 	tristate "ALi M5123 FIR (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA
+	depends on EXPERIMENTAL && IRDA
 	help
 	  Say Y here if you want to build support for the ALi M5123 FIR
 	  Controller.  The ALi M5123 FIR Controller is embedded in ALi M1543C,
@@ -385,7 +385,7 @@
 
 config VIA_FIR
 	tristate "VIA VT8231/VT1211 SIR/MIR/FIR"
-	depends on IRDA && ISA
+	depends on IRDA
 	help
 	  Say Y here if you want to build support for the VIA VT8231
 	  and VIA VT1211 IrDA controllers, found on the motherboards using
