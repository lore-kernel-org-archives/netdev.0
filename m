From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] net: remove never used forwarding_accel_ops pointer from net_device
Date: Mon, 23 Mar 2015 18:40:02 +0100
Message-ID: <73a15123e8cbe6771ac6659ba39e17b3ea84975c.1427131748.git.hannes@stressinduktion.org>
Cc: John Fastabend <john.r.fastabend@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:48206 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752573AbbCWRkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:40:08 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id A2D932064C
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 13:40:05 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
Hi John,

I guess it slipped in by accident?

Bye,
Hannes


 include/linux/netdevice.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5ae69e7..08c4ab3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1342,7 +1342,6 @@ enum netdev_priv_flags {
  *	@netdev_ops:	Includes several pointers to callbacks,
  *			if one wants to override the ndo_*() functions
  *	@ethtool_ops:	Management operations
- *	@fwd_ops:	Management operations
  *	@header_ops:	Includes callbacks for creating,parsing,caching,etc
  *			of Layer 2 headers.
  *
@@ -1551,7 +1550,6 @@ struct net_device {
 #endif
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
-	const struct forwarding_accel_ops *fwd_ops;
 #ifdef CONFIG_NET_SWITCHDEV
 	const struct swdev_ops *swdev_ops;
 #endif
-- 
2.1.0
