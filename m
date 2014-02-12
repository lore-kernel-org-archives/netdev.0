From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] net: remove useless if check from register_netdevice()
Date: Wed, 12 Feb 2014 11:45:52 +0400
Message-ID: <1392191152-24182-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36409 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbaBLHqY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 02:46:24 -0500
Received: by mail-la0-f49.google.com with SMTP id y1so6636941lam.22
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 23:46:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove useless if check from register_netdevice()

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4ad1b78..4be9a37 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
 		if (ret) {
-			if (ret > 0)
-				ret = -EIO;
+            ret = -EIO;
 			goto out;
 		}
 	}
-- 
1.8.3.2
