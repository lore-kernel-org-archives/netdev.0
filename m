From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: ipvlan: Use NF_IP_PRI_LAST as hook priority instead of INT_MAX
Date: Sun, 27 Nov 2016 18:24:05 +0800
Message-ID: <1480242245-7516-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:59207 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753517AbcK0KYv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 05:24:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

It is better to use NF_IP_PRI_LAST instead of INT_MAX as hook priority.
The former is good at readability and easier to maintain.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ab90b22..d70d245 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -16,13 +16,13 @@
 		.hook     = ipvlan_nf_input,
 		.pf       = NFPROTO_IPV4,
 		.hooknum  = NF_INET_LOCAL_IN,
-		.priority = INT_MAX,
+		.priority = NF_IP_PRI_LAST,
 	},
 	{
 		.hook     = ipvlan_nf_input,
 		.pf       = NFPROTO_IPV6,
 		.hooknum  = NF_INET_LOCAL_IN,
-		.priority = INT_MAX,
+		.priority = NF_IP_PRI_LAST,
 	},
 };
 
-- 
1.9.1
