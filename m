From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/16) af_ir use alloc_irdadev
Date: Tue, 30 Sep 2003 15:06:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150605.65d9233e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
--- a/drivers/net/irda/w83977af_ir.c	Tue Sep 30 11:56:41 2003
+++ b/drivers/net/irda/w83977af_ir.c	Tue Sep 30 11:56:41 2003
@@ -170,8 +170,7 @@
 	/*
 	 *  Allocate new instance of the driver
 	 */
-	dev = alloc_netdev(sizeof(struct w83977af_ir), "irda%d",
-			   irda_device_setup);
+	dev = alloc_irdadev(sizeof(struct w83977af_ir));
 	if (dev == NULL) {
 		printk( KERN_ERR "IrDA: Can't allocate memory for "
 			"IrDA control block!\n");
