From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 2/2] via-rhine: free_ring should be static
Date: Fri, 15 Oct 2004 13:58:27 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015135827.2b1da377@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

free_ring is a local function

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2004-10-15 12:45:02 -07:00
+++ b/drivers/net/via-rhine.c	2004-10-15 12:45:02 -07:00
@@ -948,7 +948,7 @@
 	return 0;
 }
 
-void free_ring(struct net_device* dev)
+static void free_ring(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
