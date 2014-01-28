From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] net: Fix warning on make htmldocs caused by skbuff.c
Date: Wed, 29 Jan 2014 01:05:28 +0900
Message-ID: <1390925128-20768-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixed following Warning while executing "make htmldocs".

Warning(/net/core/skbuff.c:2164): No description found for parameter 'from'
Warning(/net/core/skbuff.c:2164): Excess function parameter 'source'
description in 'skb_zerocopy'
Replace "@source" with "@from" fixed the warning.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 15057d2..16a7c78 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2149,7 +2149,7 @@ EXPORT_SYMBOL_GPL(skb_zerocopy_headlen);
 /**
  *	skb_zerocopy - Zero copy skb to skb
  *	@to: destination buffer
- *	@source: source buffer
+ *	@from: source buffer
  *	@len: number of bytes to copy from source buffer
  *	@hlen: size of linear headroom in destination buffer
  *
-- 
1.9.rc1
