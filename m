From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/8] checksum: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:38 -0700
Message-ID: <c3c67906ed477f9f851d43d61c8d927767212458.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59453 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752133Ab3HAAcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 20:32:48 -0400
In-Reply-To: <cover.1375316912.git.joe@perches.com>
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
 include/net/checksum.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 600d1d7..8f59ca5 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -107,11 +107,11 @@ static inline void csum_replace2(__sum16 *sum, __be16 from, __be16 to)
 }
 
 struct sk_buff;
-extern void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
-				     __be32 from, __be32 to, int pseudohdr);
-extern void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
-				      const __be32 *from, const __be32 *to,
-				      int pseudohdr);
+void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
+			      __be32 from, __be32 to, int pseudohdr);
+void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
+			       const __be32 *from, const __be32 *to,
+			       int pseudohdr);
 
 static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 					    __be16 from, __be16 to,
-- 
1.8.1.2.459.gbcd45b4.dirty
