From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [drivers] add missing pci_tbl exports (pointed out by "Adam J. Richter" <adam@yggdrasil.com>)
Date: Sun, 31 Oct 2004 11:28:24 -0500
Message-ID: <200410311628.i9VGSNma017970@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com, adam@yggdrasil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

adam pointed out that i missed adding MODULE_DEVICE_TABLE when i fixed
the horizon driver.  i noticed some others were missing it as well.

please apply to 2.6.

thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/31 11:26:23-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [drivers] add missing pci_tbl exports (pointed out by "Adam J. Richter" <adam@yggdrasil.com>
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2004-10-31 11:27:09 -05:00
+++ b/drivers/atm/ambassador.c	2004-10-31 11:27:09 -05:00
@@ -2439,6 +2439,8 @@
 	{ 0, }
 };
 
+MODULE_DEVICE_TABLE(pci, amb_pci_tbl);
+
 static struct pci_driver amb_driver = {
 	.name =		"amb",
 	.probe =	amb_probe,
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2004-10-31 11:27:09 -05:00
+++ b/drivers/atm/he.c	2004-10-31 11:27:09 -05:00
@@ -3051,6 +3051,8 @@
 	{ 0, }
 };
 
+MODULE_DEVICE_TABLE(pci, he_pci_tbl);
+
 static struct pci_driver he_driver = {
 	.name =		"he",
 	.probe =	he_init_one,
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	2004-10-31 11:27:09 -05:00
+++ b/drivers/atm/horizon.c	2004-10-31 11:27:09 -05:00
@@ -2913,6 +2913,8 @@
 	{ 0, }
 };
 
+MODULE_DEVICE_TABLE(pci, hrz_pci_tbl);
+
 static struct pci_driver hrz_driver = {
 	.name =		"horizon",
 	.probe =	hrz_probe,
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	2004-10-31 11:27:09 -05:00
+++ b/drivers/atm/idt77252.c	2004-10-31 11:27:09 -05:00
@@ -3819,6 +3819,8 @@
 	{ 0, }
 };
 
+MODULE_DEVICE_TABLE(pci, idt77252_pci_tbl);
+
 static struct pci_driver idt77252_driver = {
 	.name		= "idt77252",
 	.id_table	= idt77252_pci_tbl,
