From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4/9][ATM]: [zatm] fix text section references to __init text and __initdata; should be __devinit
Date: Mon, 07 Mar 2005 17:06:13 -0500
Message-ID: <200503072206.j27M6D9x020972@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 14:29:53-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [zatm] fix text section references to __init text and __initdata; should be __devinit
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/zatm.c
#   2005/03/07 14:29:35-05:00 chas@relax.cmf.nrl.navy.mil +6 -6
#   [ATM]: [zatm] fix text section references to __init text and __initdata; should be __devinit
#   
#   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	2005-03-07 15:34:29 -05:00
+++ b/drivers/atm/zatm.c	2005-03-07 15:34:29 -05:00
@@ -1090,7 +1090,7 @@
 /*----------------------------- (E)EPROM access -----------------------------*/
 
 
-static void __init eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
+static void __devinit eprom_set(struct zatm_dev *zatm_dev,unsigned long value,
     unsigned short cmd)
 {
 	int error;
@@ -1101,7 +1101,7 @@
 }
 
 
-static unsigned long __init eprom_get(struct zatm_dev *zatm_dev,
+static unsigned long __devinit eprom_get(struct zatm_dev *zatm_dev,
     unsigned short cmd)
 {
 	unsigned int value;
@@ -1114,7 +1114,7 @@
 }
 
 
-static void __init eprom_put_bits(struct zatm_dev *zatm_dev,
+static void __devinit eprom_put_bits(struct zatm_dev *zatm_dev,
     unsigned long data,int bits,unsigned short cmd)
 {
 	unsigned long value;
@@ -1129,7 +1129,7 @@
 }
 
 
-static void __init eprom_get_byte(struct zatm_dev *zatm_dev,
+static void __devinit eprom_get_byte(struct zatm_dev *zatm_dev,
     unsigned char *byte,unsigned short cmd)
 {
 	int i;
@@ -1145,7 +1145,7 @@
 }
 
 
-static unsigned char __init eprom_try_esi(struct atm_dev *dev,
+static unsigned char __devinit eprom_try_esi(struct atm_dev *dev,
     unsigned short cmd,int offset,int swap)
 {
 	unsigned char buf[ZEPROM_SIZE];
@@ -1166,7 +1166,7 @@
 }
 
 
-static void __init eprom_get_esi(struct atm_dev *dev)
+static void __devinit eprom_get_esi(struct atm_dev *dev)
 {
 	if (eprom_try_esi(dev,ZEPROM_V1_REG,ZEPROM_V1_ESI_OFF,1)) return;
 	(void) eprom_try_esi(dev,ZEPROM_V2_REG,ZEPROM_V2_ESI_OFF,0);
