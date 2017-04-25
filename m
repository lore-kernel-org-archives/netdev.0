From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 3/8] can: remove obsolete definitions
Date: Tue, 25 Apr 2017 08:19:40 +0200
Message-ID: <20170425061945.28722-4-socketcan@hartkopp.net>
References: <20170425061945.28722-1-socketcan@hartkopp.net>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, mkl@pengutronix.de,
        dev@kicherer.org, netdev@vger.kernel.org
To: linux-can@vger.kernel.org, davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170425061945.28722-1-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

can_rx_alldev_list is a per-net data structure now. Remove it's definition
here and can_rx_dev_list too.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 net/can/af_can.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/can/af_can.h b/net/can/af_can.h
index f273c9d9b129..84a35e97c5e0 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -110,9 +110,6 @@ struct s_pstats {
 	unsigned long rcv_entries_max;
 };
 
-/* receive filters subscribed for 'all' CAN devices */
-extern struct dev_rcv_lists can_rx_alldev_list;
-
 /* function prototypes for the CAN networklayer procfs (proc.c) */
 void can_init_proc(struct net *net);
 void can_remove_proc(struct net *net);
@@ -122,6 +119,5 @@ void can_stat_update(unsigned long data);
 extern struct timer_list can_stattimer;    /* timer for statistics update */
 extern struct s_stats    can_stats;        /* packet statistics */
 extern struct s_pstats   can_pstats;       /* receive list statistics */
-extern struct hlist_head can_rx_dev_list;  /* rx dispatcher structures */
 
 #endif /* AF_CAN_H */
-- 
2.11.0

