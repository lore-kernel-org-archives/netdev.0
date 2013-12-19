From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 4/5] xfrm: fix checkpatch error
Date: Thu, 19 Dec 2013 20:22:13 +0800
Message-ID: <1387455734-7624-5-git-send-email-chenweilong@huawei.com>
References: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7766 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756167Ab3LSMWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 07:22:43 -0500
In-Reply-To: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix that "else should follow close brace '}'".

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/xfrm/xfrm_policy.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ccf3063..8be5abb 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1311,8 +1311,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 			error = (x->km.state == XFRM_STATE_ERROR ?
 				 -EINVAL : -EAGAIN);
 			xfrm_state_put(x);
-		}
-		else if (error == -ESRCH)
+		} else if (error == -ESRCH)
 			error = -EAGAIN;
 
 		if (!tmpl->optional)
-- 
1.7.12
