From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 04/15] xfrm: fix checkpatch error
Date: Tue, 14 Jan 2014 07:49:08 +0100
Message-ID: <1389682159-3260-5-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60059 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531AbaANGte (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:34 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Fix that "else should follow close brace '}'".

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index fbc72b4..b5c315e 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1316,9 +1316,9 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 			error = (x->km.state == XFRM_STATE_ERROR ?
 				 -EINVAL : -EAGAIN);
 			xfrm_state_put(x);
-		}
-		else if (error == -ESRCH)
+		} else if (error == -ESRCH) {
 			error = -EAGAIN;
+		}
 
 		if (!tmpl->optional)
 			goto fail;
-- 
1.7.9.5
