From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 53/62] net: remove the second argument of k[un]map_atomic()
Date: Sun, 27 Nov 2011 13:27:33 +0800
Message-ID: <1322371662-26166-54-git-send-email-amwang@redhat.com>
References: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Cc: akpm@linux-foundation.org, Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322371662-26166-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/kmap_skb.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
index 81e1ed7..52d0a44 100644
--- a/net/core/kmap_skb.h
+++ b/net/core/kmap_skb.h
@@ -7,12 +7,12 @@ static inline void *kmap_skb_frag(const skb_frag_t *frag)
 
 	local_bh_disable();
 #endif
-	return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
+	return kmap_atomic(skb_frag_page(frag));
 }
 
 static inline void kunmap_skb_frag(void *vaddr)
 {
-	kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
+	kunmap_atomic(vaddr);
 #ifdef CONFIG_HIGHMEM
 	local_bh_enable();
 #endif
-- 
1.7.4.4
