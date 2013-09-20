From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/11] icmp.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:28 -0700
Message-ID: <17d39f6b9a415d0c9d7a0235060f6061cffa451f.1379701322.git.joe@perches.com>
References: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/icmp.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 081439f..970028e 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -39,10 +39,10 @@ struct net_proto_family;
 struct sk_buff;
 struct net;
 
-extern void	icmp_send(struct sk_buff *skb_in,  int type, int code, __be32 info);
-extern int	icmp_rcv(struct sk_buff *skb);
-extern void	icmp_err(struct sk_buff *, u32 info);
-extern int	icmp_init(void);
-extern void	icmp_out_count(struct net *net, unsigned char type);
+void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info);
+int icmp_rcv(struct sk_buff *skb);
+void icmp_err(struct sk_buff *skb, u32 info);
+int icmp_init(void);
+void icmp_out_count(struct net *net, unsigned char type);
 
 #endif	/* _ICMP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
