From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V4 5/8] net/route: export symbol ip_tos2prio
Date: Thu, 29 Mar 2012 17:03:35 +0200
Message-ID: <1333033418-1669-6-git-send-email-amirv@mellanox.com>
References: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:42769 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759454Ab2C2PEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 11:04:02 -0400
In-Reply-To: <1333033418-1669-1-git-send-email-amirv@mellanox.com>
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
