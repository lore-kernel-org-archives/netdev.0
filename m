From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH]  [ATM]: [idt77252] vfree() checking cleanups
  [ATM]: [idt77252] vfree() checking cleanups
Date: Tue, 18 Jan 2005 14:10:19 -0500
Message-ID: <200501181910.j0IJAJi5022407@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/14 08:57:04-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [idt77252] vfree() checking cleanups
#   
#   Signed-off by: James Lamanna <jlamanna@gmail.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/idt77252.c
#   2005/01/14 08:56:46-05:00 chas@relax.cmf.nrl.navy.mil +3 -6
#   [ATM]: [idt77252] vfree() checking cleanups
#   
#   Signed-off by: James Lamanna <jlamanna@gmail.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	2005-01-14 09:02:26 -05:00
+++ b/drivers/atm/idt77252.c	2005-01-14 09:02:26 -05:00
@@ -3136,14 +3136,11 @@
 		}
 	}
 
-	if (card->soft_tst)
-		vfree(card->soft_tst);
+	vfree(card->soft_tst);
 
-	if (card->scd2vc)
-		vfree(card->scd2vc);
+	vfree(card->scd2vc);
 
-	if (card->vcs)
-		vfree(card->vcs);
+	vfree(card->vcs);
 
 	if (card->raw_cell_hnd) {
 		pci_free_consistent(card->pcidev, 2 * sizeof(u32),
