From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: remove redundant declarations
Date: Fri, 06 Jul 2012 08:34:35 +0200
Message-ID: <1341556475.3265.80.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:35042 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753604Ab2GFGem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 02:34:42 -0400
Received: by eeit10 with SMTP id t10so3475690eei.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 23:34:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

remove redundant declarations, they belong in include/net/tcp.h

Signed-off-by: Eric Dumazet <edumazet@google.com>
--
 net/ipv6/syncookies.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 8e951d8..7bf3cc4 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -21,9 +21,6 @@
 #include <net/ipv6.h>
 #include <net/tcp.h>
 
-extern int sysctl_tcp_syncookies;
-extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
-
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
