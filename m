From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/16) ali-ircc use alloc_irdadev
Date: Tue, 30 Sep 2003 15:02:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930150247.421659e8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nru a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
--- a/drivers/net/irda/ali-ircc.c	Tue Sep 30 11:56:26 2003
+++ b/drivers/net/irda/ali-ircc.c	Tue Sep 30 11:56:26 2003
@@ -254,7 +254,7 @@
 	if ((ali_ircc_setup(info)) == -1)
 		return -1;
 		
-	dev = alloc_netdev(sizeof(*self), "irda%d", irda_device_setup);
+	dev = alloc_irdadev(sizeof(*self));
 	if (dev == NULL) {
 		ERROR("%s(), can't allocate memory for control block!\n", __FUNCTION__);
 		return -ENOMEM;
