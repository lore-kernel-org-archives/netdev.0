From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] always set westwood rtt (trivial)
Date: Mon, 8 Mar 2004 10:17:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308101726.4d08467a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It is faster just to update the rtt even if we never use it.

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Mon Mar  8 10:10:57 2004
+++ b/include/net/tcp.h	Mon Mar  8 10:10:57 2004
@@ -2030,8 +2030,7 @@
 
 static inline void tcp_westwood_update_rtt(struct tcp_opt *tp, __u32 rtt_seq)
 {
-        if (sysctl_tcp_westwood)
-                tp->westwood.rtt = rtt_seq;
+	tp->westwood.rtt = rtt_seq;
 }
 
 void __tcp_westwood_fast_bw(struct sock *, struct sk_buff *);
