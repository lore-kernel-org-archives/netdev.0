From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/11] garp.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:25 -0700
Message-ID: <ac245c0f23dd6f797457718cfcb602a9efd43728.1379701322.git.joe@perches.com>
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
 include/net/garp.h | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/net/garp.h b/include/net/garp.h
index 834d8ad..abf33bb 100644
--- a/include/net/garp.h
+++ b/include/net/garp.h
@@ -112,19 +112,18 @@ struct garp_port {
 	struct rcu_head			rcu;
 };
 
-extern int	garp_register_application(struct garp_application *app);
-extern void	garp_unregister_application(struct garp_application *app);
-
-extern int	garp_init_applicant(struct net_device *dev,
-				    struct garp_application *app);
-extern void	garp_uninit_applicant(struct net_device *dev,
-				      struct garp_application *app);
-
-extern int	garp_request_join(const struct net_device *dev,
-				  const struct garp_application *app,
-				  const void *data, u8 len, u8 type);
-extern void	garp_request_leave(const struct net_device *dev,
-				   const struct garp_application *app,
-				   const void *data, u8 len, u8 type);
+int garp_register_application(struct garp_application *app);
+void garp_unregister_application(struct garp_application *app);
+
+int garp_init_applicant(struct net_device *dev, struct garp_application *app);
+void garp_uninit_applicant(struct net_device *dev,
+			   struct garp_application *app);
+
+int garp_request_join(const struct net_device *dev,
+		      const struct garp_application *app, const void *data,
+		      u8 len, u8 type);
+void garp_request_leave(const struct net_device *dev,
+			const struct garp_application *app,
+			const void *data, u8 len, u8 type);
 
 #endif /* _NET_GARP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
