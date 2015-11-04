From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: add forgotten IFF_L3MDEV_SLAVE define
Date: Wed,  4 Nov 2015 14:59:06 +0100
Message-ID: <1446645546-588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, dsa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37615 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965407AbbKDN7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 08:59:10 -0500
Received: by wicfv8 with SMTP id fv8so32770764wic.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 05:59:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fixes: fee6d4c77 ("net: Add netif_is_l3_slave")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4ac653b..2c00772 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1322,6 +1322,7 @@ enum netdev_priv_flags {
 #define IFF_L3MDEV_MASTER		IFF_L3MDEV_MASTER
 #define IFF_NO_QUEUE			IFF_NO_QUEUE
 #define IFF_OPENVSWITCH			IFF_OPENVSWITCH
+#define IFF_L3MDEV_SLAVE		IFF_L3MDEV_SLAVE
 
 /**
  *	struct net_device - The DEVICE structure.
-- 
1.9.3
