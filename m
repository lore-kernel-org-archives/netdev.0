From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] allow large MTU on dummy net device
Date: Wed, 30 Jun 2004 11:37:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630113754.5ae6b14a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It is useful for testing to allow larger MTU value to be set on
the dummy network device. The current code limits it to valid Ether mtu's.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 

diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	2004-06-30 11:37:38 -07:00
+++ b/drivers/net/dummy.c	2004-06-30 11:37:38 -07:00
@@ -78,6 +78,7 @@
 	/* Fill in device structure with ethernet-generic values. */
 	ether_setup(dev);
 	dev->tx_queue_len = 0;
+	dev->change_mtu = NULL;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	SET_MODULE_OWNER(dev);
