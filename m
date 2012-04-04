From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V6 5/8] net/route: export symbol ip_tos2prio
Date: Wed,  4 Apr 2012 13:58:01 +0300
Message-ID: <1333537084-9186-6-git-send-email-amirv@mellanox.com>
References: <1333537084-9186-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:38014 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756133Ab2DDK6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 06:58:17 -0400
In-Reply-To: <1333537084-9186-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to export this to enable drivers use rt_tos2priority()

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e5647b4..634aa82 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -230,7 +230,7 @@ const __u8 ip_tos2prio[16] = {
 	TC_PRIO_INTERACTIVE_BULK,
 	ECN_OR_COST(INTERACTIVE_BULK)
 };
-
+EXPORT_SYMBOL(ip_tos2prio);
 
 /*
  * Route cache.
-- 
1.7.8.2
