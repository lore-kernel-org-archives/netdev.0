From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH 4/5] ipv6: Add IPv6 multicast address flag defines
Date: Wed, 16 Feb 2011 00:19:20 +0100
Message-ID: <1297811961-19249-5-git-send-email-linus.luessing@web.de>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:42980 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755952Ab1BOXTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 18:19:40 -0500
In-Reply-To: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds the missing IPv6 multicast address flag defines to
complement the already existing multicast address scope defines and to
be able to check these flags nicely in the future.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 include/net/ipv6.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4a3cd2c..96e50e0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -89,6 +89,18 @@
 #define IPV6_ADDR_SCOPE_GLOBAL		0x0e
=20
 /*
+ *	Addr flags
+ */
+#ifdef __KERNEL__
+#define IPV6_ADDR_MC_FLAG_TRANSIENT(a)	\
+	((a)->s6_addr[1] & 0x10)
+#define IPV6_ADDR_MC_FLAG_PREFIX(a)	\
+	((a)->s6_addr[1] & 0x20)
+#define IPV6_ADDR_MC_FLAG_RENDEZVOUS(a)	\
+	((a)->s6_addr[1] & 0x40)
+#endif
+
+/*
  *	fragmentation header
  */
=20
--=20
1.7.2.3

