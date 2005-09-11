From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  6/12] Whitespace formatting changes
Date: Sun, 11 Sep 2005 23:19:09 +0100
Message-ID: <20050911221909.GA9308@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small formatting changes.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/ax25/af_ax25.c |    2 +-
 net/rose/af_rose.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

Index: linux-cvs/net/ax25/af_ax25.c
===================================================================
--- linux-cvs.orig/net/ax25/af_ax25.c
+++ linux-cvs/net/ax25/af_ax25.c
@@ -1695,7 +1695,7 @@ static int ax25_ioctl(struct socket *soc
 		/* These two are safe on a single CPU system as only user tasks fiddle here */
 		if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
 			amount = skb->len;
-		res = put_user(amount, (int __user *)argp);
+		res = put_user(amount, (int __user *) argp);
 		break;
 	}
 
Index: linux-cvs/net/rose/af_rose.c
===================================================================
--- linux-cvs.orig/net/rose/af_rose.c
+++ linux-cvs/net/rose/af_rose.c
@@ -1243,7 +1243,7 @@ static int rose_ioctl(struct socket *soc
 		amount = sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc);
 		if (amount < 0)
 			amount = 0;
-		return put_user(amount, (unsigned int __user *)argp);
+		return put_user(amount, (unsigned int __user *) argp);
 	}
 
 	case TIOCINQ: {
@@ -1252,11 +1252,11 @@ static int rose_ioctl(struct socket *soc
 		/* These two are safe on a single CPU system as only user tasks fiddle here */
 		if ((skb = skb_peek(&sk->sk_receive_queue)) != NULL)
 			amount = skb->len;
-		return put_user(amount, (unsigned int __user *)argp);
+		return put_user(amount, (unsigned int __user *) argp);
 	}
 
 	case SIOCGSTAMP:
-		return sock_get_timestamp(sk, (struct timeval __user *)argp);
+		return sock_get_timestamp(sk, (struct timeval __user *) argp);
 
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
