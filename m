From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [MM PATCH V4 3/6] slub: mark the dangling ifdef #else of
 CONFIG_SLUB_DEBUG
Date: Tue, 29 Sep 2015 17:47:33 +0200
Message-ID: <20150929154723.14465.6260.stgit@canyon>
References: <20150929154605.14465.98995.stgit@canyon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150929154605.14465.98995.stgit@canyon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

The #ifdef of CONFIG_SLUB_DEBUG is located very far from
the associated #else.  For readability mark it with a comment.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Christoph Lameter <cl@linux.com>
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
