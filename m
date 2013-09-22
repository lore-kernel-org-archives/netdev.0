From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/12] protocol.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:17 -0700
Message-ID: <dbfddc9ae1d2e41782733149c04c31813ea689c0.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0090.hostedemail.com ([216.40.44.90]:52660 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752188Ab3IVRcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 13:32:31 -0400
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
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
 include/net/protocol.h | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 047c047..fbf7676 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -96,20 +96,20 @@ extern const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS];
 extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 #endif
 
-extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
-extern int	inet_del_protocol(const struct net_protocol *prot, unsigned char num);
-extern int	inet_add_offload(const struct net_offload *prot, unsigned char num);
-extern int	inet_del_offload(const struct net_offload *prot, unsigned char num);
-extern void	inet_register_protosw(struct inet_protosw *p);
-extern void	inet_unregister_protosw(struct inet_protosw *p);
+int inet_add_protocol(const struct net_protocol *prot, unsigned char num);
+int inet_del_protocol(const struct net_protocol *prot, unsigned char num);
+int inet_add_offload(const struct net_offload *prot, unsigned char num);
+int inet_del_offload(const struct net_offload *prot, unsigned char num);
+void inet_register_protosw(struct inet_protosw *p);
+void inet_unregister_protosw(struct inet_protosw *p);
 
 #if IS_ENABLED(CONFIG_IPV6)
-extern int	inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
-extern int	inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
-extern int	inet6_register_protosw(struct inet_protosw *p);
-extern void	inet6_unregister_protosw(struct inet_protosw *p);
+int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
+int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
+int inet6_register_protosw(struct inet_protosw *p);
+void inet6_unregister_protosw(struct inet_protosw *p);
 #endif
-extern int	inet6_add_offload(const struct net_offload *prot, unsigned char num);
-extern int	inet6_del_offload(const struct net_offload *prot, unsigned char num);
+int inet6_add_offload(const struct net_offload *prot, unsigned char num);
+int inet6_del_offload(const struct net_offload *prot, unsigned char num);
 
 #endif	/* _PROTOCOL_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
