From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/6][ATM]: [nicstar] fix some sparse warnings
Date: Tue, 22 Mar 2005 19:55:08 -0500
Message-ID: <200503230055.j2N0t7xf028383@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/22 11:35:05-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [nicstar] fix some sparse warnings
#   
#   Signed-off-by: Alexey Dobriyan <adobriyan@mail.ru>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/nicstar.h
#   2005/03/22 11:34:46-05:00 chas@relax.cmf.nrl.navy.mil +2 -2
#   [ATM]: [nicstar] fix some sparse warnings
#   
#   Signed-off-by: Alexey Dobriyan <adobriyan@mail.ru>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/nicstar.c
#   2005/03/22 11:34:46-05:00 chas@relax.cmf.nrl.navy.mil +2 -2
#   [ATM]: [nicstar] fix some sparse warnings
#   
#   Signed-off-by: Alexey Dobriyan <adobriyan@mail.ru>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	2005-03-22 19:50:00 -05:00
+++ b/drivers/atm/nicstar.c	2005-03-22 19:50:00 -05:00
@@ -350,7 +350,7 @@
    kfree(card->rsq.org);
    kfree(card->tsq.org);
    free_irq(card->pcidev->irq, card);
-   iounmap((void *) card->membase);
+   iounmap(card->membase);
    kfree(card);
 }
 
@@ -976,7 +976,7 @@
    }
    if (error >= 4)
    {
-      iounmap((void *) card->membase);
+      iounmap(card->membase);
    }
    if (error >= 3)
    {
diff -Nru a/drivers/atm/nicstar.h b/drivers/atm/nicstar.h
--- a/drivers/atm/nicstar.h	2005-03-22 19:50:00 -05:00
+++ b/drivers/atm/nicstar.h	2005-03-22 19:50:00 -05:00
@@ -739,8 +739,8 @@
 
 typedef struct vc_map
 {
-   volatile int tx:1;				/* TX vc? */
-   volatile int rx:1;				/* RX vc? */
+   volatile unsigned int tx:1;				/* TX vc? */
+   volatile unsigned int rx:1;				/* RX vc? */
    struct atm_vcc *tx_vcc, *rx_vcc;
    struct sk_buff *rx_iov;		/* RX iovector skb */
    scq_info *scq;			/* To keep track of the SCQ */
