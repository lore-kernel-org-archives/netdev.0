From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/6][ATM]: [zatm] fix sparse warning
Date: Tue, 22 Mar 2005 19:54:43 -0500
Message-ID: <200503230054.j2N0sg7s028376@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/22 09:55:38-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [zatm] fix sparse warning
#   
#   Signed-off-by: Alexey Dobriyan <adobriyan@mail.ru>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/zatm.c
#   2005/03/22 09:55:19-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [zatm] fix sparse warning
#   
#   Signed-off-by: Alexey Dobriyan <adobriyan@mail.ru>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	2005-03-22 19:50:21 -05:00
+++ b/drivers/atm/zatm.c	2005-03-22 19:50:21 -05:00
@@ -411,7 +411,7 @@
 #if 0
 printk("dummy: 0x%08lx, 0x%08lx\n",dummy[0],dummy[1]);
 #endif
-		size = error ? 0 : ntohs(((u16 *) skb->data)[cells*
+		size = error ? 0 : ntohs(((__be16 *) skb->data)[cells*
 		    ATM_CELL_PAYLOAD/sizeof(u16)-3]);
 		EVENT("got skb 0x%lx, size %d\n",(unsigned long) skb,size);
 		chan = (here[3] & uPD98401_AAL5_CHAN) >>
