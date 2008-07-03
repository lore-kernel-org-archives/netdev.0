From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 02/39]: pkt_sched: Remove comment reference to old style TX
 locking.
Date: Thu, 03 Jul 2008 00:02:18 -0700 (PDT)
Message-ID: <20080703.000218.65542674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Matheos.Worku-UdXhSnd/wVw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


We haven't had netdev->tbusy in many years :)

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/sched/sch_api.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index c40773c..365a84c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -99,7 +99,7 @@ static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
    ---requeue
 
    requeues once dequeued packet. It is used for non-standard or
-   just buggy devices, which can defer output even if dev->tbusy=0.
+   just buggy devices, which can defer output even if netif_queue_stopped()=0.
 
    ---reset
 
-- 
1.5.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
