From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] net: vnet: relocate netlink code section comment
Date: Sun, 19 Jul 2015 10:40:50 +0300
Message-ID: <7f4c030ea15ee6217af4809c834a7cbebcd66709.1437291650.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org, Baruch Siach <baruch@tkos.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:34322 "EHLO
	mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbbGSHlf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jul 2015 03:41:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The veth_setup() routine and the VETH_FEATURES macro are also part of the
netlink interface (referenced from struct rtnl_link_ops). Include them under
the netlink code section comment.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/veth.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index c8186ffda1a3..791fc1e13bc4 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -292,6 +292,10 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_get_iflink		= veth_get_iflink,
 };
 
+/*
+ * netlink interface
+ */
+
 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |    \
 		       NETIF_F_HW_CSUM | NETIF_F_RXCSUM | NETIF_F_HIGHDMA | \
 		       NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |	    \
@@ -321,10 +325,6 @@ static void veth_setup(struct net_device *dev)
 	dev->hw_enc_features = VETH_FEATURES;
 }
 
-/*
- * netlink interface
- */
-
 static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
-- 
2.1.4
