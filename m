From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/12] ipx.h: Remove extern from function prototypes
Date: Sat, 21 Sep 2013 10:22:43 -0700
Message-ID: <aed828a0b08b947467bf8009e8225c3abdfe78c0.1379783995.git.joe@perches.com>
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
 include/net/ipx.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index c1fec6b..9e9e354 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -123,23 +123,23 @@ extern struct list_head ipx_routes;
 extern rwlock_t ipx_routes_lock;
 
 extern struct list_head ipx_interfaces;
-extern struct ipx_interface *ipx_interfaces_head(void);
+struct ipx_interface *ipx_interfaces_head(void);
 extern spinlock_t ipx_interfaces_lock;
 
 extern struct ipx_interface *ipx_primary_net;
 
-extern int ipx_proc_init(void);
-extern void ipx_proc_exit(void);
+int ipx_proc_init(void);
+void ipx_proc_exit(void);
 
-extern const char *ipx_frame_name(__be16);
-extern const char *ipx_device_name(struct ipx_interface *intrfc);
+const char *ipx_frame_name(__be16);
+const char *ipx_device_name(struct ipx_interface *intrfc);
 
 static __inline__ void ipxitf_hold(struct ipx_interface *intrfc)
 {
 	atomic_inc(&intrfc->refcnt);
 }
 
-extern void ipxitf_down(struct ipx_interface *intrfc);
+void ipxitf_down(struct ipx_interface *intrfc);
 
 static __inline__ void ipxitf_put(struct ipx_interface *intrfc)
 {
-- 
1.8.1.2.459.gbcd45b4.dirty
