From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 39/47] netfilter: ebtables: fix indent on if statements
Date: Mon,  4 Sep 2017 00:42:46 +0200
Message-ID: <1504478574-13281-4-git-send-email-pablo@netfilter.org>
References: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53062 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753359AbdICWnK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 18:43:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 76F6A190F67
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:42:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 67428B5027
        for <netdev@vger.kernel.org>; Mon,  4 Sep 2017 00:42:43 +0200 (CEST)
In-Reply-To: <1504478574-13281-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The returns on some if statements are not indented correctly,
add in the missing tab.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebt_ip.c  | 4 ++--
 net/bridge/netfilter/ebt_ip6.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index d06968bdf5ec..2b46c50abce0 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -64,14 +64,14 @@ ebt_ip_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			if (NF_INVF(info, EBT_IP_DPORT,
 				    dst < info->dport[0] ||
 				    dst > info->dport[1]))
-			return false;
+				return false;
 		}
 		if (info->bitmask & EBT_IP_SPORT) {
 			u32 src = ntohs(pptr->src);
 			if (NF_INVF(info, EBT_IP_SPORT,
 				    src < info->sport[0] ||
 				    src > info->sport[1]))
-			return false;
+				return false;
 		}
 	}
 	return true;
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 4617491be41e..2a5a52a53ec4 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -89,7 +89,7 @@ ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			if (NF_INVF(info, EBT_IP6_SPORT,
 				    src < info->sport[0] ||
 				    src > info->sport[1]))
-			return false;
+				return false;
 		}
 		if ((info->bitmask & EBT_IP6_ICMP6) &&
 		    NF_INVF(info, EBT_IP6_ICMP6,
-- 
2.1.4
