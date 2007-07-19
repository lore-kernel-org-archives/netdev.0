From: Brian King <brking@linux.vnet.ibm.com>
Subject: [PATCH 3/4] ibmveth: Add ethtool TSO handlers
Date: Thu, 19 Jul 2007 10:48:20 -0500
Message-ID: <200707191548.l6JFmKi3032157@d03av03.boulder.ibm.com>
References: <1184860086366-patch-mail.ibm.com>
Cc: rcjenn@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, brking@linux.vnet.ibm.com
To: santil@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:59157 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756631AbXGSPsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 11:48:35 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6JFmY8h024545
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 11:48:34 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6JFmURj238986
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:48:31 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6JFmLw9032210
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:48:21 -0600
In-Reply-To: <1184860086366-patch-mail.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add handlers for get_tso and get_ufo to prevent errors being printed
by ethtool.

Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
---

 linux-2.6-bjking1/drivers/net/ibmveth.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff -puN drivers/net/ibmveth.c~ibmveth_ethtool_get_tso drivers/net/ibmveth.c
--- linux-2.6/drivers/net/ibmveth.c~ibmveth_ethtool_get_tso	2007-07-19 08:39:31.000000000 -0500
+++ linux-2.6-bjking1/drivers/net/ibmveth.c	2007-07-19 08:39:31.000000000 -0500
@@ -761,7 +761,9 @@ static const struct ethtool_ops netdev_e
 	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ibmveth_set_tx_csum,
 	.get_rx_csum		= ibmveth_get_rx_csum,
-	.set_rx_csum		= ibmveth_set_rx_csum
+	.set_rx_csum		= ibmveth_set_rx_csum,
+	.get_tso			= ethtool_op_get_tso,
+	.get_ufo			= ethtool_op_get_ufo
 };
 
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
_
