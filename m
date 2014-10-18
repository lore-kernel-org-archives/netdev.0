From: Balavasu <kp.balavasu@gmail.com>
Subject: [PATCH 1/2] staging: lustre: lnet: lnet: do not initialise 0
Date: Sat, 18 Oct 2014 09:33:30 +0530
Message-ID: <20141018040330.GA23492@vasu-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the checkpatch.pl issue
Error:do not initialise statics to 0 or NULL

Signed-off-by: Balavasu <kp.balavasu@gmail.com>
---
 drivers/staging/lustre/lnet/lnet/router.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index b5b8fb5..b6edf1f 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -46,7 +46,7 @@ MODULE_PARM_DESC(small_router_buffers, "# of small (1 page) messages to buffer i
 static int large_router_buffers;
 module_param(large_router_buffers, int, 0444);
 MODULE_PARM_DESC(large_router_buffers, "# of large messages to buffer in the router");
-static int peer_buffer_credits = 0;
+static int peer_buffer_credits;
 module_param(peer_buffer_credits, int, 0444);
 MODULE_PARM_DESC(peer_buffer_credits, "# router buffer credits per peer");
 
@@ -80,7 +80,7 @@ lnet_peer_buffer_credits(lnet_ni_t *ni)
 
 #endif
 
-static int check_routers_before_use = 0;
+static int check_routers_before_use = {0};
 module_param(check_routers_before_use, int, 0444);
 MODULE_PARM_DESC(check_routers_before_use, "Assume routers are down and ping them before use");
 
@@ -245,7 +245,7 @@ lnet_find_net_locked (__u32 net)
 
 static void lnet_shuffle_seed(void)
 {
-	static int seeded = 0;
+	static int seeded;
 	int lnd_type, seed[2];
 	struct timeval tv;
 	lnet_ni_t *ni;
@@ -1584,8 +1584,8 @@ lnet_notify (lnet_ni_t *ni, lnet_nid_t nid, int alive, unsigned long when)
 void
 lnet_router_checker (void)
 {
-	static time_t last = 0;
-	static int    running = 0;
+	static time_t last;
+	static int    running;
 
 	time_t	    now = get_seconds();
 	int	       interval = now - last;
-- 
1.9.1
