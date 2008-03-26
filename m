From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/2 net-2.6.26] [NETNS]: Compilation fix for include/linux/netdevice.h.
Date: Wed, 26 Mar 2008 10:40:58 +0300
Message-ID: <1206517259-29152-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:52941 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751084AbYCZHki (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 03:40:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit commit c346dca10840a874240c78efe3f39acf4312a1f2
([NET] NETNS: Omit net_device->nd_net without CONFIG_NET_NS)
breaks compilation with CONFIG_NET_NS set.

Fix the typo.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d146be4..06ca84d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -756,7 +756,7 @@ static inline
 void dev_net_set(struct net_device *dev, const struct net *net)
 {
 #ifdef CONFIG_NET_NS
-	dev->nd_dev = net;
+	dev->nd_net = net;
 #endif
 }
 
-- 
1.5.3.rc5

