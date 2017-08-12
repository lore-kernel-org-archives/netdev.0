From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 31/51] ss: Drop useless assignment
Date: Sat, 12 Aug 2017 14:04:50 +0200
Message-ID: <20170812120510.28750-32-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50143 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752114AbdHLMGH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:06:07 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After '*b = *a', 'b->next' already has the same value as 'a->next'.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 5ea388fbf1c1a..d767b1103ea81 100644
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
