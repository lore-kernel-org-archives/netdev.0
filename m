From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/12] scm.h: Remove extern from function prototypes
Date: Sun, 22 Sep 2013 10:32:24 -0700
Message-ID: <3abdad0f2a5221b8cc5fb0084d5c221451d2071a.1379870986.git.joe@perches.com>
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
 include/net/scm.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 8de2d37..262532d 100644
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -33,11 +33,11 @@ struct scm_cookie {
 #endif
 };
 
-extern void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm);
-extern void scm_detach_fds_compat(struct msghdr *msg, struct scm_cookie *scm);
-extern int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
-extern void __scm_destroy(struct scm_cookie *scm);
-extern struct scm_fp_list * scm_fp_dup(struct scm_fp_list *fpl);
+void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm);
+void scm_detach_fds_compat(struct msghdr *msg, struct scm_cookie *scm);
+int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
+void __scm_destroy(struct scm_cookie *scm);
+struct scm_fp_list *scm_fp_dup(struct scm_fp_list *fpl);
 
 #ifdef CONFIG_SECURITY_NETWORK
 static __inline__ void unix_get_peersec_dgram(struct socket *sock, struct scm_cookie *scm)
-- 
1.8.1.2.459.gbcd45b4.dirty
