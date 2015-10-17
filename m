From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 31/35] netfilter: ipv4: label placement
Date: Sat, 17 Oct 2015 13:33:06 +0200
Message-ID: <1445081590-2924-32-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48455 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbbJQL0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:32 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>

Whitespace cleansing: Labels should not be indented.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 2 +-
 net/ipv4/netfilter/ip_tables.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2dad3e1..7300616 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -468,7 +468,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 42d0946..3be2a4d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -549,7 +549,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				pos = newpos;
 			}
 		}
-		next:
+next:
 		duprintf("Finished chain %u\n", hook);
 	}
 	return 1;
-- 
2.1.4
