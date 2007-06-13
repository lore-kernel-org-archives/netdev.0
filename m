From: Patrick McHardy <kaber@trash.net>
Subject: [NET 01/18]: Mark struct net_device * argument to netdev_priv const
Date: Wed, 13 Jun 2007 18:50:43 +0200 (MEST)
Message-ID: <20070613165040.7780.42139.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35927 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758736AbXFMQup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:50:45 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Mark struct net_device * argument to netdev_priv const

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2c029e7d78d67b07ecccc6cc138ded377021555a
tree 415a297754ec7f62f3dfe46f22171de88aa22d2e
parent 14e26eae98ec9a02ebb4b17ddb689f9b92d76ad7
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:44:49 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:28 +0200

 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a70f55..94cc77c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -546,7 +546,7 @@ struct net_device
 #define	NETDEV_ALIGN		32
 #define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
-static inline void *netdev_priv(struct net_device *dev)
+static inline void *netdev_priv(const struct net_device *dev)
 {
 	return (char *)dev + ((sizeof(struct net_device)
 					+ NETDEV_ALIGN_CONST)
