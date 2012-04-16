From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: fix sparse warning for cgw_list
Date: Mon, 16 Apr 2012 21:32:25 +0200
Message-ID: <1334604746-24556-2-git-send-email-mkl@pengutronix.de>
References: <1334604746-24556-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Daniel Baluta <daniel.baluta@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1334604746-24556-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Baluta <daniel.baluta@gmail.com>

Make cgw_list static to remove the following sparse warning:
net/can/gw.c:69:1: warning: symbol 'cgw_list' was not declared.
Should it be static?

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 net/can/gw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/can/gw.c b/net/can/gw.c
index 3d79b12..b41acf2 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -66,7 +66,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Oliver Hartkopp <oliver.hartkopp@volkswagen.de>");
 MODULE_ALIAS("can-gw");
 
-HLIST_HEAD(cgw_list);
+static HLIST_HEAD(cgw_list);
 static struct notifier_block notifier;
 
 static struct kmem_cache *cgw_cache __read_mostly;
-- 
1.7.4.1

