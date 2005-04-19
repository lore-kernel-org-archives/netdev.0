From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/irda/irport.c: cleanups
Date: Tue, 19 Apr 2005 04:41:33 +0200
Message-ID: <20050419024133.GV5489@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: irda-users@lists.sourceforge.net
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- make a needlessly global function static
- remove the unneeded global function irport_probe

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/irda/irport.c |   15 +--------------
 1 files changed, 1 insertion(+), 14 deletions(-)

--- linux-2.6.12-rc2-mm3-full/drivers/net/irda/irport.c.old	2005-04-19 03:06:12.000000000 +0200
+++ linux-2.6.12-rc2-mm3-full/drivers/net/irda/irport.c	2005-04-19 03:06:45.000000000 +0200
@@ -286,19 +286,6 @@
 }
 
 /*
- * Function irport_probe (void)
- *
- *    Start IO port 
- *
- */
-int irport_probe(int iobase)
-{
-	IRDA_DEBUG(4, "%s(), iobase=%#x\n", __FUNCTION__, iobase);
-
-	return 0;
-}
-
-/*
  * Function irport_get_fcr (speed)
  *
  *    Compute value of fcr
@@ -383,7 +370,7 @@
  *    we cannot use schedule_timeout() when we are in interrupt context
  *
  */
-int __irport_change_speed(struct irda_task *task)
+static int __irport_change_speed(struct irda_task *task)
 {
 	struct irport_cb *self;
 	__u32 speed = (__u32) task->param;
