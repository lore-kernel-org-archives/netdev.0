From: Xunlei Pang <xlpang@redhat.com>
Subject: [PATCH] fib_trie: Fix the description of pos and bits
Date: Thu, 18 Aug 2016 12:33:28 +0800
Message-ID: <1471494808-22475-1-git-send-email-xlpang@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xunlei Pang <xlpang@redhat.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1) Fix one typo: s/tn/tp/
2) Fix the description about the "u" bits.

Signed-off-by: Xunlei Pang <xlpang@redhat.com>
---
 net/ipv4/fib_trie.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index d07fc07..eb7c5d1 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -249,7 +249,7 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
  * index into the parent's child array. That is, they will be used to find
  * 'n' among tp's children.
  *
- * The bits from (n->pos + n->bits) to (tn->pos - 1) - "S" - are skipped bits
+ * The bits from (n->pos + n->bits) to (tp->pos - 1) - "S" - are skipped bits
  * for the node n.
  *
  * All the bits we have seen so far are significant to the node n. The rest
@@ -258,7 +258,7 @@ static inline unsigned long get_index(t_key key, struct key_vector *kv)
  * The bits from (n->pos) to (n->pos + n->bits - 1) - "C" - are the index into
  * n's child array, and will of course be different for each child.
  *
- * The rest of the bits, from 0 to (n->pos + n->bits), are completely unknown
+ * The rest of the bits, from 0 to (n->pos -1) - "u" - are completely unknown
  * at this point.
  */
 
-- 
1.8.3.1
