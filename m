From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/9][ATM]: [lanai] use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
Date: Mon, 07 Mar 2005 17:03:44 -0500
Message-ID: <200503072203.j27M3i0u020879@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 14:02:03-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [lanai] use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
#   
#   Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/lanai.c
#   2005/03/07 14:01:44-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [lanai] use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
#   
#   Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2005-03-07 15:32:25 -05:00
+++ b/drivers/atm/lanai.c	2005-03-07 15:32:26 -05:00
@@ -1964,7 +1964,7 @@
 		return -ENXIO;
 	}
 	pci_set_master(pci);
-	if (pci_set_dma_mask(pci, 0xFFFFFFFF) != 0) {
+	if (pci_set_dma_mask(pci, DMA_32BIT_MASK) != 0) {
 		printk(KERN_WARNING DEV_LABEL
 		    "(itf %d): No suitable DMA available.\n", lanai->number);
 		return -EBUSY;
