From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH] net/tulip/xircom_cb.c: remove superfulous priv assignment
Date: Wed, 8 Aug 2007 13:20:26 +0200
Message-ID: <200708081320.26756.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:4561 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbXHHLU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 07:20:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

	Unpatched version does sth like this:

dev = alloc_etherdev(...
private = netdev_priv(dev);
...
dev->priv = private;

which doesn't make much sense (does it?) because this is done in
alloc_netdev() already.

struct net_device *alloc_netdev(...
{
...
	if (sizeof_priv)
		dev->priv = netdev_priv(dev);

This patch removes superfluous code.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/tulip/xircom_cb.c | 32853 -> 32831 (-22 bytes)
 drivers/net/tulip/xircom_cb.o | 123984 -> 123984 (0 bytes)

 drivers/net/tulip/xircom_cb.c |    1 -
 1 file changed, 1 deletion(-)

--- linux-2.6.23-rc1-mm2-a/drivers/net/tulip/xircom_cb.c	2007-08-01 08:43:46.000000000 +0200
+++ linux-2.6.23-rc1-mm2-b/drivers/net/tulip/xircom_cb.c	2007-08-08 11:06:22.000000000 +0200
@@ -271,7 +271,6 @@ static int __devinit xircom_probe(struct
 	dev->hard_start_xmit = &xircom_start_xmit;
 	dev->stop = &xircom_close;
 	dev->get_stats = &xircom_get_stats;
-	dev->priv = private;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = &xircom_poll_controller;
 #endif
