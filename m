From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 10/16] netfilter: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:36:33 +0200
Message-ID: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/netfilter/ip6t_ipv6header.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 54bd979..8b14744 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -94,7 +94,6 @@ ipv6header_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 			break;
 		default:
 			return false;
-			break;
 		}
 
 		nexthdr = hp->nexthdr;
-- 
1.8.4.5
