From: Imre Deak <imre.deak@intel.com>
Subject: [PATCH v2 7/8] net/tipc: take msecs_to_jiffies_timeout into use
Date: Tue, 14 May 2013 17:48:37 +0300
Message-ID: <1368542918-8861-8-git-send-email-imre.deak@intel.com>
References: <1368542918-8861-1-git-send-email-imre.deak@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368542918-8861-1-git-send-email-imre.deak@intel.com>
In-Reply-To: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use msecs_to_jiffies_timeout instead of open-coding the same.

Signed-off-by: Imre Deak <imre.deak@intel.com>
---
 net/tipc/core.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 0207db0..b24e2fc 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -133,7 +133,7 @@ static inline void k_init_timer(struct timer_list *timer, Handler routine,
  */
 static inline void k_start_timer(struct timer_list *timer, unsigned long msec)
 {
-	mod_timer(timer, jiffies + msecs_to_jiffies(msec) + 1);
+	mod_timer(timer, jiffies + msecs_to_jiffies_timeout(msec));
 }
 
 /**
-- 
1.7.10.4
