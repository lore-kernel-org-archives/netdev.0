From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5/6][ATM]: [lanai] alpha build fixes
Date: Tue, 22 Mar 2005 19:56:36 -0500
Message-ID: <200503230056.j2N0uZcf028407@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/22 15:01:18-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [lanai] alpha build fixes
#
#   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/lanai.c
#   2005/03/22 15:01:00-05:00 chas@relax.cmf.nrl.navy.mil +1 -0
#   [ATM]: [lanai] alpha build fixes
#
#   Signed-off-by: Jeff Garzik <jgarzik@pobox.com>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2005-03-22 19:49:16 -05:00
+++ b/drivers/atm/lanai.c	2005-03-22 19:49:16 -05:00
@@ -61,6 +61,7 @@
 #include <asm/byteorder.h>
 #include <linux/spinlock.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/interrupt.h>
