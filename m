From: Alexander Couzens <lynxis@fe80.eu>
Subject: [PATCH] l2tp_eth: allow to set a specific mac address
Date: Wed, 19 Nov 2014 13:24:39 +0100
Message-ID: <1416399879-3164-1-git-send-email-lynxis@fe80.eu>
Cc: Alexander Couzens <lynxis@fe80.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.base45.de ([80.241.61.77]:43750 "EHLO mail.base45.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbaKSMsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 07:48:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Couzens <lynxis@fe80.eu>
---
 net/l2tp/l2tp_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index edb78e6..781b3a2 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -126,6 +126,7 @@ static struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_uninit		= l2tp_eth_dev_uninit,
 	.ndo_start_xmit		= l2tp_eth_dev_xmit,
 	.ndo_get_stats64	= l2tp_eth_get_stats64,
+	.ndo_set_mac_address	= eth_mac_addr,
 };
 
 static void l2tp_eth_dev_setup(struct net_device *dev)
-- 
2.1.3
