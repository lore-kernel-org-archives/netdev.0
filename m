From: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
Subject: [PATCH] net: Remove trailing whitespace in tcp.h icmp.c syncookies.c
Date: Mon, 20 Oct 2014 18:15:50 +0900
Message-ID: <1413796550-14127-1-git-send-email-nakayamakenjiro@gmail.com>
Cc: netdev@vger.kernel.org,
	Kenjiro Nakayama <nakayamakenjiro@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove trailing whitespace in tcp.h icmp.c syncookies.c

Signed-off-by: Kenjiro Nakayama <nakayamakenjiro@gmail.com>
---
 include/net/tcp.h     | 12 ++++++------
 net/ipv6/icmp.c       |  1 -
 net/ipv6/syncookies.c |  1 -
 3 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 4062b4f..c73fc14 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -55,9 +55,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define MAX_TCP_HEADER	(128 + MAX_HEADER)
 #define MAX_TCP_OPTION_SPACE 40
 
-/* 
+/*
  * Never offer a window over 32767 without using window scaling. Some
- * poor stacks do signed 16bit maths! 
+ * poor stacks do signed 16bit maths!
  */
 #define MAX_TCP_WINDOW		32767U
 
@@ -167,7 +167,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 /*
  *	TCP option
  */
- 
+
 #define TCPOPT_NOP		1	/* Padding */
 #define TCPOPT_EOL		0	/* End of options */
 #define TCPOPT_MSS		2	/* Segment size negotiating */
@@ -1104,16 +1104,16 @@ static inline int tcp_win_from_space(int space)
 		space - (space>>sysctl_tcp_adv_win_scale);
 }
 
-/* Note: caller must be prepared to deal with negative returns */ 
+/* Note: caller must be prepared to deal with negative returns */
 static inline int tcp_space(const struct sock *sk)
 {
 	return tcp_win_from_space(sk->sk_rcvbuf -
 				  atomic_read(&sk->sk_rmem_alloc));
-} 
+}
 
 static inline int tcp_full_space(const struct sock *sk)
 {
-	return tcp_win_from_space(sk->sk_rcvbuf); 
+	return tcp_win_from_space(sk->sk_rcvbuf);
 }
 
 static inline void tcp_openreq_init(struct request_sock *req,
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 97ae700..62c1037 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -1009,4 +1009,3 @@ struct ctl_table * __net_init ipv6_icmp_sysctl_init(struct net *net)
 	return table;
 }
 #endif
-
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 2f25cb6..0e26e79 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -269,4 +269,3 @@ out_free:
 	reqsk_free(req);
 	return NULL;
 }
-
-- 
1.9.3
