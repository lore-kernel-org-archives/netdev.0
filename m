From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/12] request_sock.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:20 -0700
Message-ID: <bec351fc6068b45ffff56683af1ebed6271843db.1379870986.git.joe@perches.com>
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
 include/net/request_sock.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 59795e4..65c3e516 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -43,7 +43,7 @@ struct request_sock_ops {
 					   struct request_sock *req);
 };
 
-extern int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
+int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
 
 /* struct request_sock - mini sock to represent a connection request
  */
@@ -162,13 +162,13 @@ struct request_sock_queue {
 					     */
 };
 
-extern int reqsk_queue_alloc(struct request_sock_queue *queue,
-			     unsigned int nr_table_entries);
+int reqsk_queue_alloc(struct request_sock_queue *queue,
+		      unsigned int nr_table_entries);
 
-extern void __reqsk_queue_destroy(struct request_sock_queue *queue);
-extern void reqsk_queue_destroy(struct request_sock_queue *queue);
-extern void reqsk_fastopen_remove(struct sock *sk,
-				  struct request_sock *req, bool reset);
+void __reqsk_queue_destroy(struct request_sock_queue *queue);
+void reqsk_queue_destroy(struct request_sock_queue *queue);
+void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
+			   bool reset);
 
 static inline struct request_sock *
 	reqsk_queue_yank_acceptq(struct request_sock_queue *queue)
-- 
1.8.1.2.459.gbcd45b4.dirty
