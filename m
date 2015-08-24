From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net-next: Fix warning while make xmldocs caused by skbuff.c
Date: Mon, 24 Aug 2015 22:56:54 +0900
Message-ID: <1440424614-471-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, corbet@lwn.net,
	linux-media@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix following warnings.

.//net/core/skbuff.c:407: warning: No description found
for parameter 'len'
.//net/core/skbuff.c:407: warning: Excess function parameter
 'length' description in '__netdev_alloc_skb'
.//net/core/skbuff.c:476: warning: No description found
 for parameter 'len'
.//net/core/skbuff.c:476: warning: Excess function parameter
'length' description in '__napi_alloc_skb'

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 net/core/skbuff.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7b84330..dad4dd3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -392,7 +392,7 @@ EXPORT_SYMBOL(napi_alloc_frag);
 /**
  *	__netdev_alloc_skb - allocate an skbuff for rx on a specific device
  *	@dev: network device to receive on
- *	@length: length to allocate
+ *	@len: length to allocate
  *	@gfp_mask: get_free_pages mask, passed to alloc_skb
  *
  *	Allocate a new &sk_buff and assign it a usage count of one. The
@@ -461,7 +461,7 @@ EXPORT_SYMBOL(__netdev_alloc_skb);
 /**
  *	__napi_alloc_skb - allocate skbuff for rx in a specific NAPI instance
  *	@napi: napi instance this buffer was allocated for
- *	@length: length to allocate
+ *	@len: length to allocate
  *	@gfp_mask: get_free_pages mask, passed to alloc_skb and alloc_pages
  *
  *	Allocate a new sk_buff for use in NAPI receive.  This buffer will
-- 
2.5.0.234.gefc8a62
