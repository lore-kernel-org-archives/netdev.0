From: roy.qing.li@gmail.com
Subject: [PATCH] tcp: remove unnecessary assignment.
Date: Mon, 29 Sep 2014 15:04:37 +0800
Message-ID: <1411974277-7236-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41342 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaI2HEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 03:04:39 -0400
Received: by mail-pd0-f174.google.com with SMTP id y13so348286pdi.5
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 00:04:39 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id gz1sm11398791pbb.8.2014.09.29.00.04.36
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 00:04:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

This variable i is overwritten to 0 by following code

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/tcp_fastopen.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 9771563..815c85e 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -115,7 +115,7 @@ static bool tcp_fastopen_cookie_gen(struct request_sock *req,
 
 		if (__tcp_fastopen_cookie_gen(&ip6h->saddr, &tmp)) {
 			struct in6_addr *buf = (struct in6_addr *) tmp.val;
-			int i = 4;
+			int i;
 
 			for (i = 0; i < 4; i++)
 				buf->s6_addr32[i] ^= ip6h->daddr.s6_addr32[i];
-- 
1.7.10.4
