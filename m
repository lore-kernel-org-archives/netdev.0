From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/12] ping.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:16 -0700
Message-ID: <b692aba58032f629907ea2d462c99b87906645ca.1379870986.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
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
 include/net/ping.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ping.h b/include/net/ping.h
index 5db0224..3f67704 100644
--- a/include/net/ping.h
+++ b/include/net/ping.h
@@ -103,8 +103,8 @@ void ping_seq_stop(struct seq_file *seq, void *v);
 int ping_proc_register(struct net *net, struct ping_seq_afinfo *afinfo);
 void ping_proc_unregister(struct net *net, struct ping_seq_afinfo *afinfo);
 
-extern int __init ping_proc_init(void);
-extern void ping_proc_exit(void);
+int __init ping_proc_init(void);
+void ping_proc_exit(void);
 #endif
 
 void __init ping_init(void);
-- 
1.8.1.2.459.gbcd45b4.dirty
