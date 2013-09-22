From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/12] secure_seq.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:25 -0700
Message-ID: <08f707d15513cc60b0ba0e5b877badcd1ac4e875.1379870986.git.joe@perches.com>
References: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
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
 include/net/secure_seq.h | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index 6ca975b..52c1a90 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,19 +3,19 @@
 
 #include <linux/types.h>
 
-extern void net_secret_init(void);
-extern __u32 secure_ip_id(__be32 daddr);
-extern __u32 secure_ipv6_id(const __be32 daddr[4]);
-extern u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
-extern u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
-				      __be16 dport);
-extern __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
-					__be16 sport, __be16 dport);
-extern __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
-					  __be16 sport, __be16 dport);
-extern u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
-				       __be16 sport, __be16 dport);
-extern u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
-					 __be16 sport, __be16 dport);
+void net_secret_init(void);
+__u32 secure_ip_id(__be32 daddr);
+__u32 secure_ipv6_id(const __be32 daddr[4]);
+u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
+u32 secure_ipv6_port_ephemeral(const __be32 *saddr, const __be32 *daddr,
+			       __be16 dport);
+__u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
+				 __be16 sport, __be16 dport);
+__u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
+				   __be16 sport, __be16 dport);
+u64 secure_dccp_sequence_number(__be32 saddr, __be32 daddr,
+				__be16 sport, __be16 dport);
+u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
+				  __be16 sport, __be16 dport);
 
 #endif /* _NET_SECURE_SEQ */
-- 
1.8.1.2.459.gbcd45b4.dirty
