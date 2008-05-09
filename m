From: Brice Goglin <brice@myri.com>
Subject: [PATCH 08/16] myri10ge: trivial formatting fix
Date: Fri, 09 May 2008 02:19:08 +0200
Message-ID: <4823987C.9030707@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1813 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765352AbYEIAqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:46:13 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add some blank lines to uniformize the code and match
the upstream code.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:05:30.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:10:49.000000000 +0200
@@ -1328,7 +1328,7 @@
 	ptr = mgp->product_code_string;
 	if (ptr == NULL) {
 		printk(KERN_ERR "myri10ge: %s: Missing product code\n",
-			netdev->name);
+		       netdev->name);
 		return 0;
 	}
 	for (i = 0; i < 3; i++, ptr++) {
@@ -1362,6 +1362,7 @@
 myri10ge_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	coal->rx_coalesce_usecs = mgp->intr_coal_delay;
 	return 0;
 }
@@ -1421,6 +1422,7 @@
 static u32 myri10ge_get_rx_csum(struct net_device *netdev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	if (mgp->csum_flag)
 		return 1;
 	else
@@ -1430,6 +1432,7 @@
 static int myri10ge_set_rx_csum(struct net_device *netdev, u32 csum_enabled)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+
 	if (csum_enabled)
 		mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	else


