From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH nf-next 2/6] netfilter-ipv4: label placement
Date: Wed, 14 Oct 2015 23:17:04 +0100
Message-ID: <1444861028-21556-3-git-send-email-ipm@chirality.org.uk>
References: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1444861028-21556-1-git-send-email-ipm@chirality.org.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Whitespace cleansing: Labels should not be indented.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
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
1.9.1

