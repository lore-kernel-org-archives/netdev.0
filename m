From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] more const in skbuff
Date: Thu, 18 Sep 2003 10:27:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918102709.34211ee5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More test inline functions should take const args.

diff -Nru a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h	Thu Sep 18 10:24:35 2003
+++ b/include/linux/skbuff.h	Thu Sep 18 10:24:35 2003
@@ -306,7 +306,7 @@
  *
  *	Returns true if the queue is empty, false otherwise.
  */
-static inline int skb_queue_empty(struct sk_buff_head *list)
+static inline int skb_queue_empty(const struct sk_buff_head *list)
 {
 	return list->next == (struct sk_buff *)list;
 }
@@ -357,7 +357,7 @@
  *	one of multiple shared copies of the buffer. Cloned buffers are
  *	shared data so must not be written to under normal circumstances.
  */
-static inline int skb_cloned(struct sk_buff *skb)
+static inline int skb_cloned(const struct sk_buff *skb)
 {
 	return skb->cloned && atomic_read(&skb_shinfo(skb)->dataref) != 1;
 }
@@ -369,7 +369,7 @@
  *	Returns true if more than one person has a reference to this
  *	buffer.
  */
-static inline int skb_shared(struct sk_buff *skb)
+static inline int skb_shared(const struct sk_buff *skb)
 {
 	return atomic_read(&skb->users) != 1;
 }
@@ -477,7 +477,7 @@
  *
  *	Return the length of an &sk_buff queue.
  */
-static inline __u32 skb_queue_len(struct sk_buff_head *list_)
+static inline __u32 skb_queue_len(const struct sk_buff_head *list_)
 {
 	return list_->qlen;
 }
