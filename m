From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH] net: add comment for sock_efree() usage
Date: Tue, 10 Mar 2015 19:03:46 +0100
Message-ID: <1426010626-6482-1-git-send-email-socketcan@hartkopp.net>
Cc: eric.dumazet@gmail.com, alexander.h.duyck@redhat.com,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.216]:16180 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbCJSED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 14:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/core/sock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20..78e89eb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1655,6 +1655,10 @@ void sock_rfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_rfree);
 
+/*
+ * Buffer destructor for skbs that are not used directly in read or write
+ * path, e.g. for error handler skbs. Automatically called from kfree_skb.
+ */
 void sock_efree(struct sk_buff *skb)
 {
 	sock_put(skb->sk);
-- 
2.1.4
