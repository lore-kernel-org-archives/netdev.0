From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] appletalk: remove an unused function
Date: Fri, 29 Oct 2004 02:14:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029001439.GC29142@stusta.de>
References: <20041028221046.GI3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
Content-Disposition: inline
In-Reply-To: <20041028221046.GI3207@stusta.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ this time without the problems due to a digital signature... ]

The patch below removes an unsed function from net/appletalk/ddp.c


diffstat output:
 net/appletalk/ddp.c |    7 -------
 1 files changed, 7 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm1-full/net/appletalk/ddp.c.old	2004-10-28 23:49:44.000000000 +0200
+++ linux-2.6.10-rc1-mm1-full/net/appletalk/ddp.c	2004-10-28 23:49:57.000000000 +0200
@@ -78,13 +78,6 @@
 	sk_add_node(sk, &atalk_sockets);
 }
 
-static inline void atalk_insert_socket(struct sock *sk)
-{
-	write_lock_bh(&atalk_sockets_lock);
-	__atalk_insert_socket(sk);
-	write_unlock_bh(&atalk_sockets_lock);
-}
-
 static inline void atalk_remove_socket(struct sock *sk)
 {
 	write_lock_bh(&atalk_sockets_lock);
