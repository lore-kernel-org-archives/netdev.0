From: Jakub Wilk <jwilk@jwilk.net>
Subject: [PATCH] xfrm: Fix a typo
Date: Sat, 18 Jul 2015 14:41:51 +0200
Message-ID: <1437223311-3631-1-git-send-email-jwilk@jwilk.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5.mo2.mail-out.ovh.net ([87.98.181.248]:51003 "EHLO
	5.mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbGRN7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 09:59:17 -0400
Received: from mail184.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id 72A8FFFC8D1
	for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 14:41:56 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jakub Wilk <jwilk@jwilk.net>
---
 net/xfrm/xfrm_user.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index bd16c6c..0cebf1f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2048,7 +2048,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		xfrm_audit_policy_delete(xp, 1, true);
 	} else {
 		// reset the timers here?
-		WARN(1, "Dont know what to do with soft policy expire\n");
+		WARN(1, "Don't know what to do with soft policy expire\n");
 	}
 	km_policy_expired(xp, p->dir, up->hard, nlh->nlmsg_pid);
 
-- 
2.1.4
