From: roy.qing.li@gmail.com
Subject: [PATCH net-next] af_key: fix two typos
Date: Thu, 15 Oct 2015 17:10:20 +0800
Message-ID: <1444900220-25178-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58445 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbJOJKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 05:10:22 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.134])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id t9F9ALEW027458
	for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 02:10:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy Li <rongqing.li@windriver.com>

Signed-off-by: Roy Li <rongqing.li@windriver.com>
---
 net/key/af_key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 9e834ec..09a3985 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -261,7 +261,7 @@ static int pfkey_broadcast(struct sk_buff *skb, gfp_t allocation,
 
 		err2 = pfkey_broadcast_one(skb, &skb2, allocation, sk);
 
-		/* Error is cleare after succecful sending to at least one
+		/* Error is cleared after successful sending to at least one
 		 * registered KM */
 		if ((broadcast_flags & BROADCAST_REGISTERED) && err)
 			err = err2;
-- 
2.1.4
