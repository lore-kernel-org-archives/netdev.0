From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/9][ATM]: [lanai] atm/lanai: fix text section references to __init text; should be __devinit
Date: Mon, 07 Mar 2005 17:04:20 -0500
Message-ID: <200503072204.j27M4KYc020899@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 14:27:39-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [lanai] atm/lanai: fix text section references to __init text; should be __devinit
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/lanai.c
#   2005/03/07 14:27:20-05:00 chas@relax.cmf.nrl.navy.mil +10 -10
#   [ATM]: [lanai] atm/lanai: fix text section references to __init text; should be __devinit
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2005-03-07 15:33:49 -05:00
+++ b/drivers/atm/lanai.c	2005-03-07 15:33:49 -05:00
@@ -566,7 +566,7 @@
 	return -EIO;
 }
 
-static int __init sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
+static int __devinit sram_test_pass(const struct lanai_dev *lanai, u32 pattern)
 {
 	int offset, result = 0;
 	for (offset = 0; offset < SRAM_BYTES && result == 0; offset += 4)
@@ -574,7 +574,7 @@
 	return result;
 }
 
-static int __init sram_test_and_clear(const struct lanai_dev *lanai)
+static int __devinit sram_test_and_clear(const struct lanai_dev *lanai)
 {
 #ifdef FULL_MEMORY_TEST
 	int result;
@@ -860,7 +860,7 @@
 #ifndef READ_EEPROM
 
 /* Stub functions to use if EEPROM reading is disabled */
-static int __init eeprom_read(struct lanai_dev *lanai)
+static int __devinit eeprom_read(struct lanai_dev *lanai)
 {
 	printk(KERN_INFO DEV_LABEL "(itf %d): *NOT* reading EEPROM\n",
 	    lanai->number);
@@ -868,7 +868,7 @@
 	return 0;
 }
 
-static int __init eeprom_validate(struct lanai_dev *lanai)
+static int __devinit eeprom_validate(struct lanai_dev *lanai)
 {
 	lanai->serialno = 0;
 	lanai->magicno = EEPROM_MAGIC_VALUE;
@@ -877,7 +877,7 @@
 
 #else /* READ_EEPROM */
 
-static int __init eeprom_read(struct lanai_dev *lanai)
+static int __devinit eeprom_read(struct lanai_dev *lanai)
 {
 	int i, address;
 	u8 data;
@@ -953,7 +953,7 @@
 }
 
 /* Checksum/validate EEPROM contents */
-static int __init eeprom_validate(struct lanai_dev *lanai)
+static int __devinit eeprom_validate(struct lanai_dev *lanai)
 {
 	int i, s;
 	u32 v;
@@ -1449,7 +1449,7 @@
 #include <linux/vmalloc.h>
 #endif
 
-static int __init vcc_table_allocate(struct lanai_dev *lanai)
+static int __devinit vcc_table_allocate(struct lanai_dev *lanai)
 {
 #ifdef VCCTABLE_GETFREEPAGE
 	APRINTK((lanai->num_vci) * sizeof(struct lanai_vcc *) <= PAGE_SIZE,
@@ -1596,7 +1596,7 @@
 /*
  * Allocate service buffer and tell card about it
  */
-static int __init service_buffer_allocate(struct lanai_dev *lanai)
+static int __devinit service_buffer_allocate(struct lanai_dev *lanai)
 {
 	lanai_buf_allocate(&lanai->service, SERVICE_ENTRIES * 4, 8,
 	    lanai->pci);
@@ -1952,7 +1952,7 @@
 
 /* -------------------- PCI INITIALIZATION/SHUTDOWN: */
 
-static int __init lanai_pci_start(struct lanai_dev *lanai)
+static int __devinit lanai_pci_start(struct lanai_dev *lanai)
 {
 	struct pci_dev *pci = lanai->pci;
 	int result;
@@ -2148,7 +2148,7 @@
 /* -------------------- OPERATIONS: */
 
 /* setup a newly detected device */
-static int __init lanai_dev_open(struct atm_dev *atmdev)
+static int __devinit lanai_dev_open(struct atm_dev *atmdev)
 {
 	struct lanai_dev *lanai = (struct lanai_dev *) atmdev->dev_data;
 	unsigned long raw_base;
