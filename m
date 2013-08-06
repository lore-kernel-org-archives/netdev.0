From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 4/6] net: remove the useless comment in zerocopy_sg_from_iovec()
Date: Tue,  6 Aug 2013 17:45:06 +0800
Message-ID: <1375782308-10565-5-git-send-email-jasowang@redhat.com>
References: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375782308-10565-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/core/datagram.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index bec0867..a8a795c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -653,7 +653,6 @@ int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 			int off = base & ~PAGE_MASK;
 			int size = min_t(int, len, PAGE_SIZE - off);
 			skb_fill_page_desc(skb, i, page[i], off, size);
-			/* increase sk_wmem_alloc */
 			base += size;
 			len -= size;
 			i++;
-- 
1.7.1
