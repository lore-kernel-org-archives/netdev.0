From: Balavasu <kp.balavasu@gmail.com>
Subject: [PATCH 2/2] staging: lustre: lnet: lnet: trailing statements should
 be on next line
Date: Fri, 31 Oct 2014 23:50:40 +0530
Message-ID: <20141031182040.GA7916@vasu-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greg@kroah.com, andreas.dilger@intel.com, oleg.drokin@intel.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the checkpatch.pl issue
Error: trailing statements should be on next line

Signed-off-by: Balavasu <kp.balavasu@gmail.com>
---
 drivers/staging/lustre/lnet/lnet/router.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index cdeb246..0f569a0 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1670,13 +1670,16 @@ lnet_get_tunables (void)
 	char *s;
 
 	s = getenv("LNET_ROUTER_PING_TIMEOUT");
-	if (s != NULL) router_ping_timeout = atoi(s);
+	if (s != NULL)
+		router_ping_timeout = atoi(s);
 
 	s = getenv("LNET_LIVE_ROUTER_CHECK_INTERVAL");
-	if (s != NULL) live_router_check_interval = atoi(s);
+	if (s != NULL)
+		live_router_check_interval = atoi(s);
 
 	s = getenv("LNET_DEAD_ROUTER_CHECK_INTERVAL");
-	if (s != NULL) dead_router_check_interval = atoi(s);
+	if (s != NULL)
+		dead_router_check_interval = atoi(s);
 
 	/* This replaces old lnd_notify mechanism */
 	check_routers_before_use = 1;
-- 
1.9.1
