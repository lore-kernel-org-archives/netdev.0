From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] net: treewide: Fix typo found in DocBook/networking.xml
Date: Wed,  3 Sep 2014 12:59:15 +0900
Message-ID: <1409716755-1994-1-git-send-email-standby24x7@gmail.com>
Cc: trivial@kernel.org, Masanari Iida <standby24x7@gmail.com>
To: linux-kernel@vger.kernel.org, avem@davemloft.net,
	netdev@vger.kernel.org, rdunlap@infradead.org,
	linux-doc@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix spelling typo found in DocBook/networking.xml.
It is because the neworking.xml is generated from comments
in the source, I have to fix typo in comments within the source.

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 include/linux/netdevice.h  | 4 ++--
 include/net/wimax.h        | 2 +-
 include/trace/events/irq.h | 4 ++--
 net/core/datagram.c        | 2 +-
 net/core/gen_estimator.c   | 2 +-
 net/core/gen_stats.c       | 2 +-
 net/core/skbuff.c          | 4 ++--
 net/core/sock.c            | 4 ++--
 net/socket.c               | 2 +-
 9 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 039b237..d2b1704 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3249,7 +3249,7 @@ static inline int __dev_uc_sync(struct net_device *dev,
 }
 
 /**
- *  __dev_uc_unsync - Remove synchonized addresses from device
+ *  __dev_uc_unsync - Remove synchronized addresses from device
  *  @dev:  device to sync
  *  @unsync: function to call if address should be removed
  *
@@ -3293,7 +3293,7 @@ static inline int __dev_mc_sync(struct net_device *dev,
 }
 
 /**
- *  __dev_mc_unsync - Remove synchonized addresses from device
+ *  __dev_mc_unsync - Remove synchronized addresses from device
  *  @dev:  device to sync
  *  @unsync: function to call if address should be removed
  *
diff --git a/include/net/wimax.h b/include/net/wimax.h
index e52ef53..c52b685 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -290,7 +290,7 @@ struct wimax_dev;
  *     This operation has to be synchronous, and return only when the
  *     reset is complete. In case of having had to resort to bus/cold
  *     reset implying a device disconnection, the call is allowed to
- *     return inmediately.
+ *     return immediately.
  *     NOTE: wimax_dev->mutex is NOT locked when this op is being
  *     called; however, wimax_dev->mutex_reset IS locked to ensure
  *     serialization of calls to wimax_reset().
diff --git a/include/trace/events/irq.h b/include/trace/events/irq.h
index 1c09820..0db9838 100644
--- a/include/trace/events/irq.h
+++ b/include/trace/events/irq.h
@@ -107,7 +107,7 @@ DECLARE_EVENT_CLASS(softirq,
  * @vec_nr:  softirq vector number
  *
  * When used in combination with the softirq_exit tracepoint
- * we can determine the softirq handler runtine.
+ * we can determine the softirq handler runtime.
  */
 DEFINE_EVENT(softirq, softirq_entry,
 
@@ -121,7 +121,7 @@ DEFINE_EVENT(softirq, softirq_entry,
  * @vec_nr:  softirq vector number
  *
  * When used in combination with the softirq_entry tracepoint
- * we can determine the softirq handler runtine.
+ * we can determine the softirq handler runtime.
  */
 DEFINE_EVENT(softirq, softirq_exit,
 
diff --git a/net/core/datagram.c b/net/core/datagram.c
index 488dd1a..fdbc9a8 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -775,7 +775,7 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb)
 EXPORT_SYMBOL(__skb_checksum_complete);
 
 /**
- *	skb_copy_and_csum_datagram_iovec - Copy and checkum skb to user iovec.
+ *	skb_copy_and_csum_datagram_iovec - Copy and checksum skb to user iovec.
  *	@skb: skbuff
  *	@hlen: hardware length
  *	@iov: io vector
diff --git a/net/core/gen_estimator.c b/net/core/gen_estimator.c
index 6b5b6e7..9d33dff 100644
--- a/net/core/gen_estimator.c
+++ b/net/core/gen_estimator.c
@@ -197,7 +197,7 @@ struct gen_estimator *gen_find_node(const struct gnet_stats_basic_packed *bstats
  * as destination. A new timer with the interval specified in the
  * configuration TLV is created. Upon each interval, the latest statistics
  * will be read from &bstats and the estimated rate will be stored in
- * &rate_est with the statistics lock grabed during this period.
+ * &rate_est with the statistics lock grabbed during this period.
  *
  * Returns 0 on success or a negative error code.
  *
diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 9d3d9e7..2ddbce4 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -206,7 +206,7 @@ EXPORT_SYMBOL(gnet_stats_copy_queue);
  * @st: application specific statistics data
  * @len: length of data
  *
- * Appends the application sepecific statistics to the top level TLV created by
+ * Appends the application specific statistics to the top level TLV created by
  * gnet_stats_start_copy() and remembers the data for XSTATS if the dumping
  * handle is in backward compatibility mode.
  *
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index adfc7ee..2d9f117 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2647,7 +2647,7 @@ EXPORT_SYMBOL(skb_prepare_seq_read);
  * skb_seq_read() will return the remaining part of the block.
  *
  * Note 1: The size of each block of data returned can be arbitrary,
- *       this limitation is the cost for zerocopy seqeuental
+ *       this limitation is the cost for zerocopy sequential
  *       reads of potentially non linear data.
  *
  * Note 2: Fragment lists within fragments are not implemented
@@ -2781,7 +2781,7 @@ EXPORT_SYMBOL(skb_find_text);
 /**
  * skb_append_datato_frags - append the user data to a skb
  * @sk: sock  structure
- * @skb: skb structure to be appened with user data.
+ * @skb: skb structure to be appended with user data.
  * @getfrag: call back function to be used for getting the user data
  * @from: pointer to user message iov
  * @length: length of the iov message
diff --git a/net/core/sock.c b/net/core/sock.c
index f7f2352..8bde925 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -166,7 +166,7 @@ EXPORT_SYMBOL(sk_ns_capable);
 /**
  * sk_capable - Socket global capability test
  * @sk: Socket to use a capability on or through
- * @cap: The global capbility to use
+ * @cap: The global capability to use
  *
  * Test to see if the opener of the socket had when the socket was
  * created and the current process has the capability @cap in all user
@@ -183,7 +183,7 @@ EXPORT_SYMBOL(sk_capable);
  * @sk: Socket to use a capability on or through
  * @cap: The capability to use
  *
- * Test to see if the opener of the socket had when the socke was created
+ * Test to see if the opener of the socket had when the socket was created
  * and the current process has the capability @cap over the network namespace
  * the socket is a member of.
  */
diff --git a/net/socket.c b/net/socket.c
index 95ee7d8..0593ebd 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2602,7 +2602,7 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
  *
  *	This function is called by a protocol handler that wants to
  *	advertise its address family, and have it linked into the
- *	socket interface. The value ops->family coresponds to the
+ *	socket interface. The value ops->family corresponds to the
  *	socket system call protocol family.
  */
 int sock_register(const struct net_proto_family *ops)
-- 
2.1.0.24.g4109c28
