From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/16) nsc-ircc use alloc_irdadev
Date: Tue, 30 Sep 2003 15:05:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150501.10ca5113.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c	Tue Sep 30 11:56:31 2003
+++ b/drivers/net/irda/nsc-ircc.c	Tue Sep 30 11:56:31 2003
@@ -260,8 +260,7 @@
 
 	MESSAGE("%s, driver loaded (Dag Brattli)\n", driver_name);
 
-	dev = alloc_netdev(sizeof(struct nsc_ircc_cb), "irda%d",
-			   irda_device_setup);
+	dev = alloc_irdadev(sizeof(struct nsc_ircc_cb));
 	if (dev == NULL) {
 		ERROR("%s(), can't allocate memory for "
 		       "control block!\n", __FUNCTION__);
