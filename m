From: akpm@osdl.org
Subject: [patch 9/18] gcc-3.5: llc
Date: Sun, 25 Jan 2004 03:07:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7Xo25086@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/llc/llc_conn.c: In function `llc_sk_init':
net/llc/llc_conn.c:829: error: invalid lvalue in assignment



---

 25-akpm/net/llc/llc_conn.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN net/llc/llc_conn.c~gcc-35-llc net/llc/llc_conn.c
--- 25/net/llc/llc_conn.c~gcc-35-llc	Fri Jan 23 16:51:38 2004
+++ 25-akpm/net/llc/llc_conn.c	Fri Jan 23 16:51:52 2004
@@ -826,7 +826,7 @@ int llc_sk_init(struct sock* sk)
 		        * tx_win of remote LLC) */
 	skb_queue_head_init(&llc->pdu_unack_q);
 	sk->sk_backlog_rcv = llc_backlog_rcv;
-	llc_sk(sk) = llc;
+	sk->sk_protinfo = llc;
 out:
 	return rc;
 }

_
