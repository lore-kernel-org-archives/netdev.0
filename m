From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH v2 net-next] net: remove useless if check from register_netdevice()
Date: Thu, 13 Feb 2014 08:47:09 +0400
Message-ID: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
Cc: Denis Kirjanov <kda@linux-powerpc.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:57872 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbaBMIhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 03:37:55 -0500
Received: by mail-la0-f50.google.com with SMTP id ec20so8094236lab.9
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 00:37:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove useless if check from register_netdevice()

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
v1 -> v2: Fixed identation
---
 net/core/dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4ad1b78..21a72ad 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5876,8 +5876,7 @@ int register_netdevice(struct net_device *dev)
 	if (dev->netdev_ops->ndo_init) {
 		ret = dev->netdev_ops->ndo_init(dev);
 		if (ret) {
-			if (ret > 0)
-				ret = -EIO;
+			ret = -EIO;
 			goto out;
 		}
 	}
-- 
1.8.0.2
