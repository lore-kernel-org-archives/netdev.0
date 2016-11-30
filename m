From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net/rtnetlink: fix attribute name in nlmsg_size() comments
Date: Wed, 30 Nov 2016 14:30:37 +0100
Message-ID: <20161130133037.14315-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:45470 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753108AbcK3Nak (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:30:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the correct attribute constant names IFLA_GSO_MAX_{SEGS,SIZE}
instead of IFLA_MAX_GSO_{SEGS,SIZE} for the comments int nlmsg_size().

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/rtnetlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index deb35acbefd0..a6196cf844f6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -931,8 +931,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_PROMISCUITY */
 	       + nla_total_size(4) /* IFLA_NUM_TX_QUEUES */
 	       + nla_total_size(4) /* IFLA_NUM_RX_QUEUES */
-	       + nla_total_size(4) /* IFLA_MAX_GSO_SEGS */
-	       + nla_total_size(4) /* IFLA_MAX_GSO_SIZE */
+	       + nla_total_size(4) /* IFLA_GSO_MAX_SEGS */
+	       + nla_total_size(4) /* IFLA_GSO_MAX_SIZE */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
-- 
2.11.0
