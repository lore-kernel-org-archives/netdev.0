From: davej@redhat.com
Subject: [PATCH] Missing break in switch statement.
Date: Mon, 11 Aug 2003 17:48:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E19mFqr-00068T-00@tetrachloride>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is this intentional? It should at least have a 
/* FALLTHROUGH */ or similar if so.

		Dave

diff -urpN --exclude-from=/home/davej/.exclude bk-linus/net/ipv6/raw.c linux-2.5/net/ipv6/raw.c
--- bk-linus/net/ipv6/raw.c	2003-07-11 13:57:41.000000000 +0100
+++ linux-2.5/net/ipv6/raw.c	2003-07-11 14:08:05.000000000 +0100
@@ -833,6 +833,7 @@ static int rawv6_getsockopt(struct sock 
 			val = -1;
 		else
 			val = opt->offset;
+		break;
 
 	default:
 		return -ENOPROTOOPT;
