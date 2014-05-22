From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] net/xfrm/xfrm_output.c: move EXPORT_SYMBOL
Date: Thu, 22 May 2014 11:06:38 +0200
Message-ID: <1400749598-29603-4-git-send-email-steffen.klassert@secunet.com>
References: <1400749598-29603-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45170 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbaEVJGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 05:06:54 -0400
In-Reply-To: <1400749598-29603-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabian Frederick <fabf@skynet.be>

Fix checkpatch warning:
"WARNING: EXPORT_SYMBOL(foo); should immediately follow its function/variable"

Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_output.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 3bb2cdc..c51e8f7b 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -199,6 +199,7 @@ int xfrm_output(struct sk_buff *skb)
 
 	return xfrm_output2(skb);
 }
+EXPORT_SYMBOL_GPL(xfrm_output);
 
 int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 {
@@ -213,6 +214,7 @@ int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 		return -EAFNOSUPPORT;
 	return inner_mode->afinfo->extract_output(x, skb);
 }
+EXPORT_SYMBOL_GPL(xfrm_inner_extract_output);
 
 void xfrm_local_error(struct sk_buff *skb, int mtu)
 {
@@ -233,7 +235,4 @@ void xfrm_local_error(struct sk_buff *skb, int mtu)
 	afinfo->local_error(skb, mtu);
 	xfrm_state_put_afinfo(afinfo);
 }
-
-EXPORT_SYMBOL_GPL(xfrm_output);
-EXPORT_SYMBOL_GPL(xfrm_inner_extract_output);
 EXPORT_SYMBOL_GPL(xfrm_local_error);
-- 
1.7.9.5
