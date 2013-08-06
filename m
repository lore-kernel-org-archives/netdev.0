From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 2/3] netdevice: remove useless else keyword
Date: Tue,  6 Aug 2013 01:32:50 -0600
Message-ID: <1375774371-831-2-git-send-email-sakiwit@gmail.com>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54850 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab3HFHfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 03:35:03 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so362243pab.39
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 00:35:01 -0700 (PDT)
In-Reply-To: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up multiple useless else keywords. Add empty lines for
readability.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/core/dev.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 58eb802..1b0bea8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1062,9 +1062,11 @@ static int dev_get_valid_name(struct net *net,
 
 	if (strchr(name, '%'))
 		return dev_alloc_name_ns(net, dev, name);
-	else if (__dev_get_by_name(net, name))
+
+	if (__dev_get_by_name(net, name))
 		return -EEXIST;
-	else if (dev->name != name)
+
+	if (dev->name != name)
 		strlcpy(dev->name, name, IFNAMSIZ);
 
 	return 0;
