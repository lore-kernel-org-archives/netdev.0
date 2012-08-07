From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH] net:appletalk:ddp:fixed coding style issue again relating to
Date: Tue,  7 Aug 2012 19:30:20 +0530
Message-ID: <1344348020-4966-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeffrin Jose <ahiliation@yahoo.co.in>
To: acme@ghostprotocols.net, davem@davemloft.net,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm21-vm6.bullet.mail.sg3.yahoo.com ([106.10.151.37]:32585 "HELO
	nm21-vm6.bullet.mail.sg3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751690Ab2HGNxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 09:53:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed coding style issue relating to indentation in
net/appletalk/ddp.c found by checkpatch.pl tool

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/appletalk/ddp.c |   42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 4023fca..2cf1054 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1797,39 +1797,39 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	switch (cmd) {
 		/* Protocol layer */
 	case TIOCOUTQ: {
-			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
+		long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
 
-			if (amount < 0)
-				amount = 0;
-			rc = put_user(amount, (int __user *)argp);
-			break;
+		if (amount < 0)
+			amount = 0;
+		rc = put_user(amount, (int __user *)argp);
+		break;
 		}
 	case TIOCINQ: {
 			/*
 			 * These two are safe on a single CPU system as only
 			 * user tasks fiddle here
 			 */
-			struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
-			long amount = 0;
+		struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
+		long amount = 0;
 
-			if (skb)
-				amount = skb->len - sizeof(struct ddpehdr);
+		if (skb)
+			amount = skb->len - sizeof(struct ddpehdr);
 			rc = put_user(amount, (int __user *)argp);
 			break;
 		}
 	case SIOCGSTAMP:
-			rc = sock_get_timestamp(sk, argp);
-			break;
+		rc = sock_get_timestamp(sk, argp);
+		break;
 	case SIOCGSTAMPNS:
-			rc = sock_get_timestampns(sk, argp);
-			break;
+		rc = sock_get_timestampns(sk, argp);
+		break;
 		/* Routing */
 	case SIOCADDRT:
 	case SIOCDELRT:
-			rc = -EPERM;
-			if (capable(CAP_NET_ADMIN))
-				rc = atrtr_ioctl(cmd, argp);
-			break;
+		rc = -EPERM;
+		if (capable(CAP_NET_ADMIN))
+			rc = atrtr_ioctl(cmd, argp);
+		break;
 		/* Interface */
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
@@ -1838,10 +1838,10 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case SIOCDIFADDR:
 	case SIOCSARP:		/* proxy AARP */
 	case SIOCDARP:		/* proxy AARP */
-			rtnl_lock();
-			rc = atif_ioctl(cmd, argp);
-			rtnl_unlock();
-			break;
+		rtnl_lock();
+		rc = atif_ioctl(cmd, argp);
+		rtnl_unlock();
+		break;
 	}
 
 	return rc;
-- 
1.7.10
