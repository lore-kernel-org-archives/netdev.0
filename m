From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] net: Update kernel-doc for __alloc_skb()
Date: Thu, 7 Jun 2012 02:23:37 +0100
Message-ID: <1339032217.2836.61.camel@bwh-desktop.uk.solarflarecom.com>
References: <jqoe5d$fs3$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Grant Edwards <grant.b.edwards@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59815 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751724Ab2FGBXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 21:23:41 -0400
In-Reply-To: <jqoe5d$fs3$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__alloc_skb() now extends tailroom to allow the use of padding added
by the heap allocator.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/skbuff.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 016694d..1d74cea 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -160,8 +160,8 @@ static void skb_under_panic(struct sk_buff *skb, int sz, void *here)
  *	@node: numa node to allocate memory on
  *
  *	Allocate a new &sk_buff. The returned buffer has no headroom and a
- *	tail room of size bytes. The object has a reference count of one.
- *	The return is the buffer. On a failure the return is %NULL.
+ *	tail room of at least size bytes. The object has a reference count
+ *	of one. The return is the buffer. On a failure the return is %NULL.
  *
  *	Buffers may only be allocated from interrupts using a @gfp_mask of
  *	%GFP_ATOMIC.
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
