From: akpm@osdl.org
Subject: [patch 3/5] af_unix datagram getpeersec fix
Date: Fri, 30 Jun 2006 02:27:21 -0700
Message-ID: <200606300927.k5U9RLBD001462@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, cxzhang@watson.ibm.com,
	herbert@gondor.apana.org.au, jmorris@namei.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34448 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751690AbWF3J1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 05:27:34 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>

The unix_get_peersec_dgram() stub should have been inlined so that it
disappears.

Cc: James Morris <jmorris@namei.org>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Catherine Zhang <cxzhang@watson.ibm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/unix/af_unix.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/unix/af_unix.c~af_unix-datagram-getpeersec-fix net/unix/af_unix.c
--- a/net/unix/af_unix.c~af_unix-datagram-getpeersec-fix
+++ a/net/unix/af_unix.c
@@ -145,7 +145,7 @@ static inline void unix_set_secdata(stru
 	scm->seclen = *UNIXSECLEN(skb);
 }
 #else
-static void unix_get_peersec_dgram(struct sk_buff *skb)
+static inline void unix_get_peersec_dgram(struct sk_buff *skb)
 { }
 
 static inline void unix_set_secdata(struct scm_cookie *scm, struct sk_buff *skb)
_
