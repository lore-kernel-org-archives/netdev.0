From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/8] af_unix.h: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:33 -0700
Message-ID: <af5dade8ea13d08a6aca3df8198b664a022d2146.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
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
 include/net/af_unix.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index dbdfd2b..05442df 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -6,12 +6,12 @@
 #include <linux/mutex.h>
 #include <net/sock.h>
 
-extern void unix_inflight(struct file *fp);
-extern void unix_notinflight(struct file *fp);
-extern void unix_gc(void);
-extern void wait_for_unix_gc(void);
-extern struct sock *unix_get_socket(struct file *filp);
-extern struct sock *unix_peer_get(struct sock *);
+void unix_inflight(struct file *fp);
+void unix_notinflight(struct file *fp);
+void unix_gc(void);
+void wait_for_unix_gc(void);
+struct sock *unix_get_socket(struct file *filp);
+struct sock *unix_peer_get(struct sock *);
 
 #define UNIX_HASH_SIZE	256
 #define UNIX_HASH_BITS	8
@@ -71,8 +71,8 @@ long unix_inq_len(struct sock *sk);
 long unix_outq_len(struct sock *sk);
 
 #ifdef CONFIG_SYSCTL
-extern int unix_sysctl_register(struct net *net);
-extern void unix_sysctl_unregister(struct net *net);
+int unix_sysctl_register(struct net *net);
+void unix_sysctl_unregister(struct net *net);
 #else
 static inline int unix_sysctl_register(struct net *net) { return 0; }
 static inline void unix_sysctl_unregister(struct net *net) {}
-- 
1.8.1.2.459.gbcd45b4.dirty
