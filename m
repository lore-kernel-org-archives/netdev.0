From: bora.sahin@ttnet.net.tr
Subject: [PATCH 3/12] smc911x: Use SET_ETHTOOL_OPS macro
Date: Wed, 13 Sep 2006 20:54:00 +0300
Message-ID: <200609132054.00423.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:15737 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751049AbWIMSek
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:34:40 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use SET_ETHTOOL_OPS macro...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -2056,7 +2053,7 @@
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	dev->get_stats = smc911x_query_statistics;
 	dev->set_multicast_list = smc911x_set_multicast_list;
-	dev->ethtool_ops = &smc911x_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &smc911x_ethtool_ops);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = smc911x_poll_controller;
 #endif
