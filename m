From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/12] mrp.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:46 -0700
Message-ID: <98931149ac392bc49ecdf2125fa32d68fcfe67ce.1379783995.git.joe@perches.com>
References: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <005f102eb1322058f9e797a7268ae8be01ecfaae.1379783995.git.joe@perches.com>
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
 include/net/mrp.h | 26 ++++++++++++--------------
 1 file changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/net/mrp.h b/include/net/mrp.h
index 4fbf02a..687c8fe 100644
--- a/include/net/mrp.h
+++ b/include/net/mrp.h
@@ -125,19 +125,17 @@ struct mrp_port {
 	struct rcu_head			rcu;
 };
 
-extern int	mrp_register_application(struct mrp_application *app);
-extern void	mrp_unregister_application(struct mrp_application *app);
-
-extern int	mrp_init_applicant(struct net_device *dev,
-				    struct mrp_application *app);
-extern void	mrp_uninit_applicant(struct net_device *dev,
-				      struct mrp_application *app);
-
-extern int	mrp_request_join(const struct net_device *dev,
-				  const struct mrp_application *app,
-				  const void *value, u8 len, u8 type);
-extern void	mrp_request_leave(const struct net_device *dev,
-				   const struct mrp_application *app,
-				   const void *value, u8 len, u8 type);
+int mrp_register_application(struct mrp_application *app);
+void mrp_unregister_application(struct mrp_application *app);
+
+int mrp_init_applicant(struct net_device *dev, struct mrp_application *app);
+void mrp_uninit_applicant(struct net_device *dev, struct mrp_application *app);
+
+int mrp_request_join(const struct net_device *dev,
+		     const struct mrp_application *app,
+		     const void *value, u8 len, u8 type);
+void mrp_request_leave(const struct net_device *dev,
+		       const struct mrp_application *app,
+		       const void *value, u8 len, u8 type);
 
 #endif /* _NET_MRP_H */
-- 
1.8.1.2.459.gbcd45b4.dirty
