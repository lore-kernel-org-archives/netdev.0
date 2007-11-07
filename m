From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/24] [NET]: Remove unnecessary inclusion of dst.h
Date: Wed, 07 Nov 2007 22:08:21 +0800
Message-ID: <E1IplZt-0001GS-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3525 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757769AbXKGOIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:24 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Remove unnecessary inclusion of dst.h

The file net/netevent.h only refers to struct dst_entry * so it doesn't
need to include dst.h.  I've replaced it with a forward declaration.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/netevent.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netevent.h b/include/net/netevent.h
index e5d2162..e82b7ba 100644
--- a/include/net/netevent.h
+++ b/include/net/netevent.h
@@ -12,7 +12,7 @@
  */
 #ifdef __KERNEL__
 
-#include <net/dst.h>
+struct dst_entry;
 
 struct netevent_redirect {
 	struct dst_entry *old;
