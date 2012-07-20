From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 3/6] skbuff: export skb_copy_ubufs
Date: Fri, 20 Jul 2012 22:23:20 +0300
Message-ID: <e5cb1f232243cfbfde50c09089f7cf959db72c64.1342812067.git.mst@redhat.com>
References: <cover.1342812067.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1342812067.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export skb_copy_ubufs so that modules can orphan frags.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 438bbc5..368f65c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -784,7 +784,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	return 0;
 }
-
+EXPORT_SYMBOL_GPL(skb_copy_ubufs);
 
 /**
  *	skb_clone	-	duplicate an sk_buff
-- 
MST
