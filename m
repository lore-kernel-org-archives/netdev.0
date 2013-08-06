From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 1/3] sock: fix a typo in the comment
Date: Tue,  6 Aug 2013 01:32:49 -0600
Message-ID: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36717 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab3HFHe7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 03:34:59 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so364755pab.20
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 00:34:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct 'transfert' to 'transfer' to better deliver the original
author's message.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 83667de..811de47 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1579,7 +1579,7 @@ EXPORT_SYMBOL(sock_wfree);
 void skb_orphan_partial(struct sk_buff *skb)
 {
 	/* TCP stack sets skb->ooo_okay based on sk_wmem_alloc,
-	 * so we do not completely orphan skb, but transfert all
+	 * so we do not completely orphan skb, but transfer all
 	 * accounted bytes but one, to avoid unexpected reorders.
 	 */
 	if (skb->destructor == sock_wfree
