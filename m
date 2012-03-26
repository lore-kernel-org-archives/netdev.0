From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V2 6/7] net/route: export symbol ip_tos2prio
Date: Mon, 26 Mar 2012 11:07:53 +0200
Message-ID: <1332752874-8086-7-git-send-email-amirv@mellanox.com>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:53264 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754046Ab2CZJIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 05:08:21 -0400
In-Reply-To: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to export this to enable drivers use rt_tos2priority()

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 12ccf88..69e0b86 100644
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
