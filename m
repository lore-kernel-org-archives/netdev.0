From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/12] udplite.h: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 11:33:39 -0700
Message-ID: <c9da8be3fe2aec5da9e4fe64b234a02e43ee12a4.1379961014.git.joe@perches.com>
References: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0229.hostedemail.com ([216.40.44.229]:43120 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753617Ab3IWSdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 14:33:42 -0400
In-Reply-To: <445209f8885ccd8234fa787c30d63e63fc7917d7.1379961014.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/udplite.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/udplite.h b/include/net/udplite.h
index 7137545..2caadab 100644
--- a/include/net/udplite.h
+++ b/include/net/udplite.h
@@ -126,7 +126,7 @@ static inline __wsum udplite_csum(struct sk_buff *skb)
 	return skb_checksum(skb, off, len, 0);
 }
 
-extern void	udplite4_register(void);
-extern int 	udplite_get_port(struct sock *sk, unsigned short snum,
-			int (*scmp)(const struct sock *, const struct sock *));
+void udplite4_register(void);
+int udplite_get_port(struct sock *sk, unsigned short snum,
+		     int (*scmp)(const struct sock *, const struct sock *));
 #endif	/* _UDPLITE_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
