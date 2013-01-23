From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 8/8] xfrm: Remove unused defines
Date: Wed, 23 Jan 2013 09:19:04 +0100
Message-ID: <1358929144-17806-9-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50751 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab3AWITi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:38 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XFRM_REPLAY_SEQ, XFRM_REPLAY_OSEQ and XFRM_REPLAY_SEQ_MASK
were introduced years ago but actually never used.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 63445ed..421f764 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -557,10 +557,6 @@ struct xfrm_migrate {
 };
 
 #define XFRM_KM_TIMEOUT                30
-/* which seqno */
-#define XFRM_REPLAY_SEQ		1
-#define XFRM_REPLAY_OSEQ	2
-#define XFRM_REPLAY_SEQ_MASK	3
 /* what happened */
 #define XFRM_REPLAY_UPDATE	XFRM_AE_CR
 #define XFRM_REPLAY_TIMEOUT	XFRM_AE_CE
-- 
1.7.9.5
