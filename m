From: Joe Perches <joe@perches.com>
Subject: [PATCH 35/39] net/core/dev.c: Update WARN uses
Date: Sat, 30 Oct 2010 14:08:52 -0700
Message-ID: <2f05cefa4dc86594a2d7335c7978b1ae781bef0e.1288471898.git.joe@perches.com>
References: <cover.1288471897.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1288471897.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Coalesce long formats.
Add missing newlines.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 35dfb83..0f79b89 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1817,8 +1817,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 		if (dev && dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
 			dev->ethtool_ops->get_drvinfo(dev, &info);
 
-		WARN(1, "%s: caps=(0x%lx, 0x%lx) len=%d data_len=%d "
-			"ip_summed=%d",
+		WARN(1, "%s: caps=(0x%lx, 0x%lx) len=%d data_len=%d ip_summed=%d\n",
 		     info.driver, dev ? dev->features : 0L,
 		     skb->sk ? skb->sk->sk_route_caps : 0L,
 		     skb->len, skb->data_len, skb->ip_summed);
-- 
1.7.3.1.g432b3.dirty
