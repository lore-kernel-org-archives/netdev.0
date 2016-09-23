From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: fix header file comment reference to struct xfrm_replay_state_esn
Date: Fri, 23 Sep 2016 09:14:41 +0200
Message-ID: <1474614882-25253-2-git-send-email-steffen.klassert@secunet.com>
References: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45170 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756810AbcIWHOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:14:52 -0400
In-Reply-To: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Guy Briggs <rgb@tricolour.ca>

Reported-by: Paul Wouters <paul@nohats.ca>
Signed-off-by: Richard Guy Briggs <rgb@tricolour.ca>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/uapi/linux/xfrm.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 1433389..1fc62b2 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -298,7 +298,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ALG_AUTH_TRUNC,	/* struct xfrm_algo_auth */
 	XFRMA_MARK,		/* struct xfrm_mark */
 	XFRMA_TFCPAD,		/* __u32 */
-	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
+	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_state_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
 	XFRMA_PROTO,		/* __u8 */
 	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
-- 
1.9.1
