From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/8 net-2.6.25] [ARP] Remove forward declaration of neigh_changeaddr.
Date: Mon, 14 Jan 2008 17:59:58 +0300
Message-ID: <1200322801-19054-5-git-send-email-den@openvz.org>
References: <478B78CB.4030404@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:51220 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753290AbYANPAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 10:00:00 -0500
In-Reply-To: <478B78CB.4030404@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for this. It is declared in the neighbour.h

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/neighbour.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 2eab6a5..9b0b773 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -59,7 +59,6 @@ static void neigh_timer_handler(unsigned long arg);
 static void __neigh_notify(struct neighbour *n, int type, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
-void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 
 static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
-- 
1.5.3.rc5

