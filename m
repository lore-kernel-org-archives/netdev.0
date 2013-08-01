From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/8] af_rxrpc.h: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:34 -0700
Message-ID: <e5aa8f4892a700e56cdd9f3da6ca8a26dbe2fe5d.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: David Howells <dhowells@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Reflow modified prototypes to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/af_rxrpc.h | 35 ++++++++++++++++-------------------
 1 file changed, 16 insertions(+), 19 deletions(-)

diff --git a/include/net/af_rxrpc.h b/include/net/af_rxrpc.h
index 03e6e94..e797d45 100644
--- a/include/net/af_rxrpc.h
+++ b/include/net/af_rxrpc.h
@@ -31,24 +31,21 @@ enum {
 
 typedef void (*rxrpc_interceptor_t)(struct sock *, unsigned long,
 				    struct sk_buff *);
-extern void rxrpc_kernel_intercept_rx_messages(struct socket *,
-					       rxrpc_interceptor_t);
-extern struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
-						  struct sockaddr_rxrpc *,
-						  struct key *,
-						  unsigned long,
-						  gfp_t);
-extern int rxrpc_kernel_send_data(struct rxrpc_call *, struct msghdr *,
-				  size_t);
-extern void rxrpc_kernel_abort_call(struct rxrpc_call *, u32);
-extern void rxrpc_kernel_end_call(struct rxrpc_call *);
-extern bool rxrpc_kernel_is_data_last(struct sk_buff *);
-extern u32 rxrpc_kernel_get_abort_code(struct sk_buff *);
-extern int rxrpc_kernel_get_error_number(struct sk_buff *);
-extern void rxrpc_kernel_data_delivered(struct sk_buff *);
-extern void rxrpc_kernel_free_skb(struct sk_buff *);
-extern struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *,
-						   unsigned long);
-extern int rxrpc_kernel_reject_call(struct socket *);
+void rxrpc_kernel_intercept_rx_messages(struct socket *, rxrpc_interceptor_t);
+struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *,
+					   struct sockaddr_rxrpc *,
+					   struct key *,
+					   unsigned long,
+					   gfp_t);
+int rxrpc_kernel_send_data(struct rxrpc_call *, struct msghdr *, size_t);
+void rxrpc_kernel_abort_call(struct rxrpc_call *, u32);
+void rxrpc_kernel_end_call(struct rxrpc_call *);
+bool rxrpc_kernel_is_data_last(struct sk_buff *);
+u32 rxrpc_kernel_get_abort_code(struct sk_buff *);
+int rxrpc_kernel_get_error_number(struct sk_buff *);
+void rxrpc_kernel_data_delivered(struct sk_buff *);
+void rxrpc_kernel_free_skb(struct sk_buff *);
+struct rxrpc_call *rxrpc_kernel_accept_call(struct socket *, unsigned long);
+int rxrpc_kernel_reject_call(struct socket *);
 
 #endif /* _NET_RXRPC_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
