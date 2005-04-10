From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/3][ATM]: [he] Use the DMA_32BIT_MASK constant from dma-mapping.h
Date: Sun, 10 Apr 2005 11:27:01 -0400
Message-ID: <200504101527.j3AFR09g007587@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/10 10:43:13-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [he] Use the DMA_32BIT_MASK constant from dma-mapping.h
#   
#   Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/he.h
#   2005/04/10 10:42:53-04:00 chas@relax.cmf.nrl.navy.mil +0 -2
#   [ATM]: [he] Use the DMA_32BIT_MASK constant from dma-mapping.h
#   
#   Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/he.c
#   2005/04/10 10:42:53-04:00 chas@relax.cmf.nrl.navy.mil +2 -1
#   [ATM]: [he] Use the DMA_32BIT_MASK constant from dma-mapping.h
#   
#   Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2005-04-10 11:15:02 -04:00
+++ b/drivers/atm/he.c	2005-04-10 11:15:02 -04:00
@@ -70,6 +70,7 @@
 #include <linux/sched.h>
 #include <linux/timer.h>
 #include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
 #include <asm/io.h>
 #include <asm/byteorder.h>
 #include <asm/uaccess.h>
@@ -371,7 +372,7 @@
 
 	if (pci_enable_device(pci_dev))
 		return -EIO;
-	if (pci_set_dma_mask(pci_dev, HE_DMA_MASK) != 0) {
+	if (pci_set_dma_mask(pci_dev, DMA_32BIT_MASK) != 0) {
 		printk(KERN_WARNING "he: no suitable dma available\n");
 		err = -EIO;
 		goto init_one_failure;
diff -Nru a/drivers/atm/he.h b/drivers/atm/he.h
--- a/drivers/atm/he.h	2005-04-10 11:15:02 -04:00
+++ b/drivers/atm/he.h	2005-04-10 11:15:02 -04:00
@@ -380,8 +380,6 @@
 #define PCI_VENDOR_ID_FORE	0x1127
 #define PCI_DEVICE_ID_FORE_HE	0x400
 
-#define HE_DMA_MASK		0xffffffff
-
 #define GEN_CNTL_0				0x40
 #define  INT_PROC_ENBL		(1<<25)
 #define  SLAVE_ENDIAN_MODE	(1<<16)
