From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH]net:appletalk:ddp:fixed coding style issue in net/appletalk/ddp.c
Date: Thu, 26 Jul 2012 19:29:02 +0530
Message-ID: <1343311142-4539-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: acme@ghostprotocols.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed coding style issue relating to switch  and case
statement in file net/appletalk/ddp.c

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/appletalk/ddp.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 0301b32..c8bbcd2 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1798,7 +1798,7 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 
 	switch (cmd) {
 		/* Protocol layer */
-		case TIOCOUTQ: {
+	case TIOCOUTQ: {
 			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 
 			if (amount < 0)
@@ -1806,7 +1806,7 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = put_user(amount, (int __user *)argp);
 			break;
 		}
-		case TIOCINQ: {
+	case TIOCINQ: {
 			/*
 			 * These two are safe on a single CPU system as only
 			 * user tasks fiddle here
@@ -1819,27 +1819,27 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = put_user(amount, (int __user *)argp);
 			break;
 		}
-		case SIOCGSTAMP:
+	case SIOCGSTAMP:
 			rc = sock_get_timestamp(sk, argp);
 			break;
-		case SIOCGSTAMPNS:
+	case SIOCGSTAMPNS:
 			rc = sock_get_timestampns(sk, argp);
 			break;
 		/* Routing */
-		case SIOCADDRT:
-		case SIOCDELRT:
+	case SIOCADDRT:
+	case SIOCDELRT:
 			rc = -EPERM;
 			if (capable(CAP_NET_ADMIN))
 				rc = atrtr_ioctl(cmd, argp);
 			break;
 		/* Interface */
-		case SIOCGIFADDR:
-		case SIOCSIFADDR:
-		case SIOCGIFBRDADDR:
-		case SIOCATALKDIFADDR:
-		case SIOCDIFADDR:
-		case SIOCSARP:		/* proxy AARP */
-		case SIOCDARP:		/* proxy AARP */
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+	case SIOCGIFBRDADDR:
+	case SIOCATALKDIFADDR:
+	case SIOCDIFADDR:
+	case SIOCSARP:		/* proxy AARP */
+	case SIOCDARP:		/* proxy AARP */
 			rtnl_lock();
 			rc = atif_ioctl(cmd, argp);
 			rtnl_unlock();
-- 
1.7.10
