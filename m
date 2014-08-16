From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH 4/4] IPV6: checkpatch corrections
Date: Sat, 16 Aug 2014 13:04:47 +0100
Message-ID: <1408190687-28941-4-git-send-email-ipm@chirality.org.uk>
References: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:43165 "EHLO
	oak.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751536AbaHPMFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2014 08:05:00 -0400
In-Reply-To: <1408190687-28941-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

minor coding style changes to address checkpatch warnings
no differences according to objdump

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/route.c        |    3 +--
 net/ipv6/udp.c          |    3 ++-
 net/ipv6/xfrm6_tunnel.c |    9 ++++++---
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f74b041..85c11d4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2578,8 +2578,7 @@ static int rt6_fill_node(struct net *net,
 			rtm->rtm_type = RTN_UNREACHABLE;
 			break;
 		}
-	}
-	else if (rt->rt6i_flags & RTF_LOCAL)
+	} else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
 	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
 		rtm->rtm_type = RTN_LOCAL;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 84a8ba6..d07a132 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1451,7 +1451,8 @@ int __net_init udp6_proc_init(struct net *net)
 	return udp_proc_register(net, &udp6_seq_afinfo);
 }
 
-void udp6_proc_exit(struct net *net) {
+void udp6_proc_exit(struct net *net)
+{
 	udp_proc_unregister(net, &udp6_seq_afinfo);
 }
 #endif /* CONFIG_PROC_FS */
diff --git a/net/ipv6/xfrm6_tunnel.c b/net/ipv6/xfrm6_tunnel.c
index 5743044..b30eeac 100644
--- a/net/ipv6/xfrm6_tunnel.c
+++ b/net/ipv6/xfrm6_tunnel.c
@@ -268,9 +268,12 @@ static int xfrm6_tunnel_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		break;
 	case ICMPV6_PARAMPROB:
 		switch (code) {
-		case ICMPV6_HDR_FIELD: break;
-		case ICMPV6_UNK_NEXTHDR: break;
-		case ICMPV6_UNK_OPTION: break;
+		case ICMPV6_HDR_FIELD:
+			break;
+		case ICMPV6_UNK_NEXTHDR:
+			break;
+		case ICMPV6_UNK_OPTION:
+			break;
 		}
 		break;
 	default:
-- 
1.7.9.5
