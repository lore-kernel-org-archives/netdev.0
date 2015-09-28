From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 3/7] slub: mark the dangling ifdef #else of CONFIG_SLUB_DEBUG
Date: Mon, 28 Sep 2015 14:26:19 +0200
Message-ID: <20150928122619.15409.68763.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37588 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757134AbbI1M0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 08:26:21 -0400
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The #ifdef of CONFIG_SLUB_DEBUG is located very far from
the associated #else.  For readability mark it with a comment.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 024eed32da2c..1cf98d89546d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1202,7 +1202,7 @@ unsigned long kmem_cache_flags(unsigned long object_size,
 
 	return flags;
 }
-#else
+#else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
 
