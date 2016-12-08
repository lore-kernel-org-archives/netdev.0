From: kushwaha.a@samsung.com
Subject: [PATCH] net: socket: preferred __aligned(size) for control buffer
Date: Thu, 08 Dec 2016 18:21:53 +0530
Message-ID: <1481201513-20783-1-git-send-email-kushwaha.a@samsung.com>
Cc: netdev@vger.kernel.org, akkushwaha9896@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:56032 "EHLO
        mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbcLHNEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 08:04:20 -0500
Received: from epcpsbgm1new.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OHV02E5DAIHO4A0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 08 Dec 2016 21:54:19 +0900 (KST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kushwaha <kushwaha.a@samsung.com>

This patch cleanup checkpatch.pl warning
WARNING: __aligned(size) is preferred over __attribute__((aligned(size)))

Signed-off-by: Amit Kushwaha <kushwaha.a@samsung.com>
---
 net/socket.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index e631894..5835383 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1,3 +1,4 @@
+
 /*
  * NET		An implementation of the SOCKET network access protocol.
  *
@@ -1918,7 +1919,7 @@ static int ___sys_sendmsg(struct socket *sock, struct user_msghdr __user *msg,
 	struct sockaddr_storage address;
 	struct iovec iovstack[UIO_FASTIOV], *iov = iovstack;
 	unsigned char ctl[sizeof(struct cmsghdr) + 20]
-	    __attribute__ ((aligned(sizeof(__kernel_size_t))));
+				__aligned(sizeof(__kernel_size_t));
 	/* 20 is size of ipv6_pktinfo */
 	unsigned char *ctl_buf = ctl;
 	int ctl_len;
-- 
1.7.9.5
