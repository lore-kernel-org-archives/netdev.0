From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: dev_close_many() is static
Date: Thu, 20 Jan 2011 08:23:22 +0100
Message-ID: <1295508202.2653.483.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62948 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752476Ab1ATHX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 02:23:27 -0500
Received: by wwa36 with SMTP id 36so315470wwa.1
        for <netdev@vger.kernel.org>; Wed, 19 Jan 2011 23:23:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7c6a46f..c135268 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1285,7 +1285,7 @@ static int __dev_close(struct net_device *dev)
 	return __dev_close_many(&single);
 }
 
-int dev_close_many(struct list_head *head)
+static int dev_close_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
 	LIST_HEAD(tmp_list);


