From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 6/7] ss: Drop useless assignment
Date: Thu, 17 Aug 2017 19:09:30 +0200
Message-ID: <20170817170931.24089-7-phil@nwl.cc>
References: <20170817170931.24089-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58749 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751943AbdHQRKC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 13:10:02 -0400
In-Reply-To: <20170817170931.24089-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After '*b = *a', 'b->next' already has the same value as 'a->next'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 2debccce5260b..b2a7f069e294c 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1440,7 +1440,6 @@ static int remember_he(struct aafilter *a, struct hostent *he)
 			if ((b = malloc(sizeof(*b))) == NULL)
 				return cnt;
 			*b = *a;
-			b->next = a->next;
 			a->next = b;
 		}
 		memcpy(b->addr.data, *ptr, len);
-- 
2.13.1
