From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH 4/4] nets: clean up net/ipv4/tcp_ipv4.c
Date: Mon, 3 Nov 2008 18:41:56 +0800
Message-ID: <20081103104156.GE19058@ubuntu>
References: <20081102074446.GA12140@ubuntu> <490DEAD3.3030202@cosmosbay.com> <20081103082002.GG14553@ubuntu> <20081103.002808.142907024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:52796 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755041AbYKCKlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 05:41:46 -0500
Content-Disposition: inline
In-Reply-To: <20081103.002808.142907024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[PATCH 4/4] nets: clean up net/ipv4/tcp_ipv4.c

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 net/ipv4/tcp_ipv4.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ef33246..d49233f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1874,7 +1874,7 @@ static void *listening_get_next(struct seq_file *seq, void *cur)
 	struct inet_connection_sock *icsk;
 	struct hlist_node *node;
 	struct sock *sk = cur;
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 
 	if (!sk) {
@@ -1960,7 +1960,7 @@ static inline int empty_bucket(struct tcp_iter_state *st)
 
 static void *established_get_first(struct seq_file *seq)
 {
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 	void *rc = NULL;
 
@@ -2005,7 +2005,7 @@ static void *established_get_next(struct seq_file *seq, void *cur)
 	struct sock *sk = cur;
 	struct inet_timewait_sock *tw;
 	struct hlist_node *node;
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	struct net *net = seq_file_net(seq);
 
 	++st->num;
@@ -2064,7 +2064,7 @@ static void *established_get_idx(struct seq_file *seq, loff_t pos)
 static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 {
 	void *rc;
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 
 	inet_listen_lock(&tcp_hashinfo);
 	st->state = TCP_SEQ_STATE_LISTENING;
@@ -2081,7 +2081,7 @@ static void *tcp_get_idx(struct seq_file *seq, loff_t pos)
 
 static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 	st->state = TCP_SEQ_STATE_LISTENING;
 	st->num = 0;
 	return *pos ? tcp_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
@@ -2090,7 +2090,7 @@ static void *tcp_seq_start(struct seq_file *seq, loff_t *pos)
 static void *tcp_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	void *rc = NULL;
-	struct tcp_iter_state* st;
+	struct tcp_iter_state *st;
 
 	if (v == SEQ_START_TOKEN) {
 		rc = tcp_get_idx(seq, 0);
@@ -2120,7 +2120,7 @@ out:
 
 static void tcp_seq_stop(struct seq_file *seq, void *v)
 {
-	struct tcp_iter_state* st = seq->private;
+	struct tcp_iter_state *st = seq->private;
 
 	switch (st->state) {
 	case TCP_SEQ_STATE_OPENREQ:
@@ -2281,7 +2281,7 @@ static void get_timewait4_sock(struct inet_timewait_sock *tw,
 
 static int tcp4_seq_show(struct seq_file *seq, void *v)
 {
-	struct tcp_iter_state* st;
+	struct tcp_iter_state *st;
 	int len;
 
 	if (v == SEQ_START_TOKEN) {
-- 
1.5.6.3

