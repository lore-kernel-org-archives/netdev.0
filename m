From: roy.qing.li@gmail.com
Subject: [PATCH] af_key: fix two typos
Date: Thu, 22 Oct 2015 11:35:05 +0800
Message-ID: <1445484905-20361-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60101 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbbJVDfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 23:35:07 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.134])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id t9M3Z5Kj004003
	for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 20:35:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/key/af_key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 83a7068..f9c9ecb 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -261,7 +261,7 @@ static int pfkey_broadcast(struct sk_buff *skb,
 
 		err2 = pfkey_broadcast_one(skb, &skb2, GFP_ATOMIC, sk);
 
-		/* Error is cleare after succecful sending to at least one
+		/* Error is cleared after successful sending to at least one
 		 * registered KM */
 		if ((broadcast_flags & BROADCAST_REGISTERED) && err)
 			err = err2;
-- 
2.1.4
