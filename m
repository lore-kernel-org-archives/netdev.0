From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/irda/irport.c: cleanups
Date: Mon, 2 May 2005 03:46:40 +0200
Message-ID: <20050502014640.GR3592@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261640AbVEBCPx@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the following cleanups:
- make a needlessly global function static
- remove the unneeded global function irport_probe

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 19 Apr 2005

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
