From: Imre Deak <imre.deak@intel.com>
Subject: [PATCH 10/11] net/tipc: take msecs_to_jiffies_min into use
Date: Fri, 10 May 2013 15:13:28 +0300
Message-ID: <1368188011-23661-10-git-send-email-imre.deak@intel.com>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53450 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818Ab3EJMO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 May 2013 08:14:26 -0400
In-Reply-To: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use msecs_to_jiffies_min instead of open-coding the same.

Signed-off-by: Imre Deak <imre.deak@intel.com>
---
 net/tipc/core.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 0207db0..3f23e22 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -133,7 +133,7 @@ static inline void k_init_timer(struct timer_list *timer, Handler routine,
  */
 static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
 {
-	mod_timer(timer, jiffies + msecs_to_jiffies(msec) + 1);
+	mod_timer(timer, jiffies + msecs_to_jiffies_min(msec));
 }
 
 /**
-- 
1.7.10.4
