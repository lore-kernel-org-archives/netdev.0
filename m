From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 2/5] sctp: fix checkpatch errors with foo
Date: Thu, 19 Dec 2013 14:51:59 +0800
Message-ID: <1387435922-24152-3-git-send-email-wangweidong1@huawei.com>
References: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22080 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab3LSGwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 01:52:45 -0500
In-Reply-To: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix three foo type errors below:
ERROR: "(foo*)" should be "(foo *)"
ERROR: "foo * bar" should be "foo *bar"
ERROR: "foo* bar" should be "foo *bar"

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/auth.c          |  6 +++---
 net/sctp/objcnt.c        |  2 +-
 net/sctp/proc.c          |  8 ++++----
 net/sctp/sm_make_chunk.c |  2 +-
 net/sctp/sm_statefuns.c  |  2 +-
 net/sctp/socket.c        | 18 +++++++++---------
 net/sctp/sysctl.c        |  2 +-
 net/sctp/ulpqueue.c      |  4 ++--
 8 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 78767aa..889400b 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -226,9 +226,9 @@ static struct sctp_auth_bytes *sctp_auth_make_local_vector(
 				    gfp_t gfp)
 {
 	return sctp_auth_make_key_vector(
-				    (sctp_random_param_t*)asoc->c.auth_random,
-				    (sctp_chunks_param_t*)asoc->c.auth_chunks,
-				    (sctp_hmac_algo_param_t*)asoc->c.auth_hmacs,
+				    (sctp_random_param_t *)asoc->c.auth_random,
+				    (sctp_chunks_param_t *)asoc->c.auth_chunks,
+				    (sctp_hmac_algo_param_t *)asoc->c.auth_hmacs,
 				    gfp);
 }
 
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 0c28e8a..40e7fac 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -97,7 +97,7 @@ static void sctp_objcnt_seq_stop(struct seq_file *seq, void *v)
 {
 }
 
-static void * sctp_objcnt_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *sctp_objcnt_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	++*pos;
 	return (*pos >= ARRAY_SIZE(sctp_dbg_objcnt)) ? NULL : (void *)pos;
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index de32e14..63ba0bd 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -177,7 +177,7 @@ static void sctp_seq_dump_remote_addrs(struct seq_file *seq, struct sctp_associa
 	rcu_read_unlock();
 }
 
-static void * sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
+static void *sctp_eps_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	if (*pos >= sctp_ep_hashsize)
 		return NULL;
@@ -196,7 +196,7 @@ static void sctp_eps_seq_stop(struct seq_file *seq, void *v)
 }
 
 
-static void * sctp_eps_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *sctp_eps_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	if (++*pos >= sctp_ep_hashsize)
 		return NULL;
@@ -282,7 +282,7 @@ void sctp_eps_proc_exit(struct net *net)
 }
 
 
-static void * sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
+static void *sctp_assocs_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	if (*pos >= sctp_assoc_hashsize)
 		return NULL;
@@ -305,7 +305,7 @@ static void sctp_assocs_seq_stop(struct seq_file *seq, void *v)
 }
 
 
-static void * sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+static void *sctp_assocs_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	if (++*pos >= sctp_assoc_hashsize)
 		return NULL;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 439d872..d53af47 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2251,7 +2251,7 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
 	 * VIOLATION error.  We build the ERROR chunk here and let the normal
 	 * error handling code build and send the packet.
 	 */
-	if (param.v != (void*)chunk->chunk_end)
+	if (param.v != (void *)chunk->chunk_end)
 		return sctp_process_inv_paramlength(asoc, param.p, chunk, errp);
 
 	/* The only missing mandatory param possible today is
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index bc690b4..624e4ef 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4610,7 +4610,7 @@ sctp_disposition_t sctp_sf_do_prm_asoc(struct net *net,
 				       sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *repl;
-	struct sctp_association* my_asoc;
+	struct sctp_association *my_asoc;
 
 	/* The comment below says that we enter COOKIE-WAIT AFTER
 	 * sending the INIT, but that doesn't actually work in our
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 500972a..9f42c60 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -82,7 +82,7 @@ static int sctp_writeable(struct sock *sk);
 static void sctp_wfree(struct sk_buff *skb);
 static int sctp_wait_for_sndbuf(struct sctp_association *, long *timeo_p,
 				size_t msg_len);
-static int sctp_wait_for_packet(struct sock * sk, int *err, long *timeo_p);
+static int sctp_wait_for_packet(struct sock *sk, int *err, long *timeo_p);
 static int sctp_wait_for_connect(struct sctp_association *, long *timeo_p);
 static int sctp_wait_for_accept(struct sock *sk, long timeo);
 static void sctp_wait_for_close(struct sock *sk, long timeo);
@@ -952,7 +952,7 @@ int sctp_asconf_mgmt(struct sctp_sock *sp, struct sctp_sockaddr_entry *addrw)
  *
  * Returns 0 if ok, <0 errno code on error.
  */
-static int sctp_setsockopt_bindx(struct sock* sk,
+static int sctp_setsockopt_bindx(struct sock *sk,
 				 struct sockaddr __user *addrs,
 				 int addrs_size, int op)
 {
@@ -1039,7 +1039,7 @@ out:
  * Common routine for handling connect() and sctp_connectx().
  * Connect will come in with just a single address.
  */
-static int __sctp_connect(struct sock* sk,
+static int __sctp_connect(struct sock *sk,
 			  struct sockaddr *kaddrs,
 			  int addrs_size,
 			  sctp_assoc_t *assoc_id)
@@ -1299,7 +1299,7 @@ out_free:
  *
  * Returns >=0 if ok, <0 errno code on error.
  */
-static int __sctp_setsockopt_connectx(struct sock* sk,
+static int __sctp_setsockopt_connectx(struct sock *sk,
 				      struct sockaddr __user *addrs,
 				      int addrs_size,
 				      sctp_assoc_t *assoc_id)
@@ -1337,7 +1337,7 @@ static int __sctp_setsockopt_connectx(struct sock* sk,
  * This is an older interface.  It's kept for backward compatibility
  * to the option that doesn't provide association id.
  */
-static int sctp_setsockopt_connectx_old(struct sock* sk,
+static int sctp_setsockopt_connectx_old(struct sock *sk,
 					struct sockaddr __user *addrs,
 					int addrs_size)
 {
@@ -1350,7 +1350,7 @@ static int sctp_setsockopt_connectx_old(struct sock* sk,
  * indication to the call.  Error is always negative and association id is
  * always positive.
  */
-static int sctp_setsockopt_connectx(struct sock* sk,
+static int sctp_setsockopt_connectx(struct sock *sk,
 				    struct sockaddr __user *addrs,
 				    int addrs_size)
 {
@@ -1373,7 +1373,7 @@ static int sctp_setsockopt_connectx(struct sock* sk,
  * addrs_num structure member.  That way we can re-use the existing
  * code.
  */
-static int sctp_getsockopt_connectx3(struct sock* sk, int len,
+static int sctp_getsockopt_connectx3(struct sock *sk, int len,
 				     char __user *optval,
 				     int __user *optlen)
 {
@@ -5475,7 +5475,7 @@ static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
 		return -EINVAL;
 
 	if (asoc)
-		ch = (struct sctp_chunks_param*)asoc->c.auth_chunks;
+		ch = (struct sctp_chunks_param *)asoc->c.auth_chunks;
 	else
 		ch = sctp_sk(sk)->ep->auth_chunk_list;
 
@@ -6417,7 +6417,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
  * Note: This function is the same function as in core/datagram.c
  * with a few modifications to make lksctp work.
  */
-static int sctp_wait_for_packet(struct sock * sk, int *err, long *timeo_p)
+static int sctp_wait_for_packet(struct sock *sk, int *err, long *timeo_p)
 {
 	int error;
 	DEFINE_WAIT(wait);
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 9dd5ac0..7135e61 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -424,7 +424,7 @@ void sctp_sysctl_net_unregister(struct net *net)
 	kfree(table);
 }
 
-static struct ctl_table_header * sctp_sysctl_header;
+static struct ctl_table_header *sctp_sysctl_header;
 
 /* Sysctl registration.  */
 void sctp_sysctl_register(void)
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 2d96640..c700369 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -43,9 +43,9 @@
 #include <net/sctp/sm.h>
 
 /* Forward declarations for internal helpers.  */
-static struct sctp_ulpevent * sctp_ulpq_reasm(struct sctp_ulpq *ulpq,
+static struct sctp_ulpevent *sctp_ulpq_reasm(struct sctp_ulpq *ulpq,
 					      struct sctp_ulpevent *);
-static struct sctp_ulpevent * sctp_ulpq_order(struct sctp_ulpq *,
+static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *,
 					      struct sctp_ulpevent *);
 static void sctp_ulpq_reasm_drain(struct sctp_ulpq *ulpq);
 
-- 
1.7.12
