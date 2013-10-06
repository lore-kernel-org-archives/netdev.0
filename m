From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] net: af802154: Fix wrong structure declaration
Date: Sun,  6 Oct 2013 14:44:01 -0700
Message-ID: <1381095841-15031-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Guenter Roeck <linux@roeck-us.net>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:36535 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522Ab3JFVrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Oct 2013 17:47:36 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro12so6308739pbb.27
        for <netdev@vger.kernel.org>; Sun, 06 Oct 2013 14:47:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_devce doesn't exist.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 net/ieee802154/af802154.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/af802154.h b/net/ieee802154/af802154.h
index b1ec525..62f5f63 100644
--- a/net/ieee802154/af802154.h
+++ b/net/ieee802154/af802154.h
@@ -25,7 +25,7 @@
 #define AF802154_H
 
 struct sk_buff;
-struct net_devce;
+struct net_device;
 extern struct proto ieee802154_raw_prot;
 extern struct proto ieee802154_dgram_prot;
 void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb);
-- 
1.7.9.7
