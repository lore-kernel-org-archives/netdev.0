From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2-RFC 3/6] skbuff: export skb_copy_ubufs
Date: Thu, 17 May 2012 00:16:05 +0300
Message-ID: <8643d6f149bdb78c1edb9b78881b380221b87583.1337202879.git.mst@redhat.com>
References: <cover.1337202879.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758903Ab2EPWIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 18:08:44 -0400
Content-Disposition: inline
In-Reply-To: <cover.1337202879.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export skb_copy_ubufs so that modules can orphan frags.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 596e392..f6dda83 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -741,7 +741,7 @@ int skb_copy_ubufs(struct sk_buff *skb, gfp_t gfp_mask)
 	skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
 	return 0;
 }
-
+EXPORT_SYMBOL_GPL(skb_copy_ubufs);
 
 /**
  *	skb_clone	-	duplicate an sk_buff
-- 
MST
