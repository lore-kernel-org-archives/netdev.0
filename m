From: kaber@trash.net
Subject: [PATCH 8/8] netfilter: ipset: fix compiler warnings "'hash_ip4_data_next' declared inline after being called"
Date: Thu, 21 Jul 2011 12:17:56 +0200
Message-ID: <1311243476-18236-9-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Friesen <chris.friesen@genband.com>

Some gcc versions warn about prototypes without "inline" when the declaration
includes the "inline" keyword. The fix generates a false error message
"marked inline, but without a definition" with sparse below 0.4.2.

Signed-off-by: Chris Friesen <chris.friesen@genband.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 1e7f759..b89fb79 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -392,7 +392,7 @@ retry:
 	return 0;
 }
 
-static void
+static inline void
 type_pf_data_next(struct ip_set_hash *h, const struct type_pf_elem *d);
 
 /* Add an element to a hash and update the internal counters when succeeded,
-- 
1.7.2.3

