From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 03/15] xfrm: remove unused function
Date: Wed, 1 Feb 2017 09:17:45 +0100
Message-ID: <1485937077-612-4-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37026 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751437AbdBAISI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:08 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Has been ifdef'd out for more than 10 years, remove it.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/xfrm4_state.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 542074c..d6660a8 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -90,11 +90,3 @@ void __init xfrm4_state_init(void)
 {
 	xfrm_state_register_afinfo(&xfrm4_state_afinfo);
 }
-
-#if 0
-void __exit xfrm4_state_fini(void)
-{
-	xfrm_state_unregister_afinfo(&xfrm4_state_afinfo);
-}
-#endif  /*  0  */
-
-- 
1.9.1
