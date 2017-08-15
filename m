From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] netfilter: fix indent on if statements
Date: Tue, 15 Aug 2017 10:50:34 +0100
Message-ID: <20170815095034.21058-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S . Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The returns on some if statements are not indented correctly,
add in the missing tab.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
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
2.11.0
