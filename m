From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (16/16) irda-usb use alloc_irdadev
Date: Tue, 30 Sep 2003 15:21:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930152100.51ff2efc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use alloc_irdadev here; worth looking into putting control block
in space allocated for dev->priv, but not now.

diff -Nru a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
--- a/drivers/net/irda/irda-usb.c	Tue Sep 30 11:56:34 2003
+++ b/drivers/net/irda/irda-usb.c	Tue Sep 30 11:56:34 2003
@@ -1176,7 +1176,7 @@
 	memset(self->speed_buff, 0, IRDA_USB_SPEED_MTU);
 
 	/* Create a network device for us */
-	netdev = alloc_netdev(0, "irda%d",  irda_device_setup);
+	netdev = alloc_irdadev(0);
 	if (!netdev) {
 		ERROR("%s(), alloc_net_dev() failed!\n", __FUNCTION__);
 		return -ENOMEM;
