From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [fore200e] fix warnings related to dma_addr_t
Date: Thu, 23 Sep 2004 14:44:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409231844.i8NIi0gD018156@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave,

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 10:50:50-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [fore200e] fix warnings related to dma_addr_t
# 
diff -Nru a/drivers/atm/fore200e.h b/drivers/atm/fore200e.h
--- a/drivers/atm/fore200e.h	2004-09-23 14:39:11 -04:00
+++ b/drivers/atm/fore200e.h	2004-09-23 14:39:11 -04:00
@@ -565,7 +565,7 @@
 typedef struct chunk {
     void* alloc_addr;    /* base address of allocated chunk */
     void* align_addr;    /* base address of aligned chunk   */
-    u32   dma_addr;      /* DMA address of aligned chunk    */
+    dma_addr_t dma_addr; /* DMA address of aligned chunk    */
     int   direction;     /* direction of DMA mapping        */
     u32   alloc_size;    /* length of allocated chunk       */
     u32   align_size;    /* length of aligned chunk         */
