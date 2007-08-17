From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 3/6] ibmveth: Add ethtool TSO handlers
Date: Fri, 17 Aug 2007 09:16:37 -0500
Message-ID: <200708171416.l7HEGbwx003958@d01av02.pok.ibm.com>
References: <11873601831813-patch-mail.ibm.com>
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	brking@linux.vnet.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:50600 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754636AbXHQOQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 10:16:39 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7HEGcVc008565
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 10:16:38 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7HEGcQm549482
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 10:16:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7HEGcsu004008
	for <netdev@vger.kernel.org>; Fri, 17 Aug 2007 10:16:38 -0400
In-Reply-To: <11873601831813-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add handlers for get_tso and get_ufo to prevent errors being printed
by ethtool.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_get_tso drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_get_tso	2007-08-08 10:46:28.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-08-08 10:46:28.000000000 -0500
@@ -767,6 +767,8 @@ static const struct ethtool_ops netdev_e
 	.set_tx_csum		= ibmveth_set_tx_csum,
 	.get_rx_csum		= ibmveth_get_rx_csum,
 	.set_rx_csum		= ibmveth_set_rx_csum,
+	.get_tso			= ethtool_op_get_tso,
+	.get_ufo			= ethtool_op_get_ufo,
 };
 
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
_
