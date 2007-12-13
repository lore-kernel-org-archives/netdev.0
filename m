From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 8/8] Remove unused IPV4TYPE macros
Date: Thu, 13 Dec 2007 15:39:01 -0800
Message-ID: <1197589141-7020-8-git-send-email-joe@perches.com>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
 <1197589141-7020-2-git-send-email-joe@perches.com>
 <1197589141-7020-3-git-send-email-joe@perches.com>
 <1197589141-7020-4-git-send-email-joe@perches.com>
 <1197589141-7020-5-git-send-email-joe@perches.com>
 <1197589141-7020-6-git-send-email-joe@perches.com>
 <1197589141-7020-7-git-send-email-joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4216 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760085AbXLMXjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 18:39:11 -0500
In-Reply-To: <1197589141-7020-7-git-send-email-joe@perches.com>
Message-Id: <885ea24008e2b1c07e6bff0344f260a0ff104a35.1197432867.git.joe@perches.com>
In-Reply-To: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
References: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 include/linux/in.h |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index f8d6073..27d8a5a 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -272,12 +272,6 @@ static inline bool ipv4_is_zeronet(__be32 addr)
 	return (addr & htonl(0xff000000)) == htonl(0x00000000);
 }
 
-#define LOOPBACK(x)		ipv4_is_loopback(x)
-#define MULTICAST(x)		ipv4_is_multicast(x)
-#define BADCLASS(x)		ipv4_is_badclass(x)
-#define ZERONET(x)		ipv4_is_zeronet(x)
-#define LOCAL_MCAST(x)		ipv4_is_local_multicast(x)
-
 /* Special-Use IPv4 Addresses (RFC3330) */
 
 static inline bool ipv4_is_private_10(__be32 addr)
@@ -316,12 +310,4 @@ static inline bool ipv4_is_test_198(__be32 addr)
 }
 #endif
 
-#define PRIVATE_10(x)		ipv4_is_private_10(x)
-#define LINKLOCAL_169(x)	ipv4_is_linklocal_169(x)
-#define PRIVATE_172(x)		ipv4_is_private_172(x)
-#define TEST_192(x)		ipv4_is_test_192(x)
-#define ANYCAST_6TO4(x)		ipv4_is_anycast_6to4(x)
-#define PRIVATE_192(x)		ipv4_is_private_192(x)
-#define TEST_198(x)		ipv4_is_test_198(x)
-
 #endif	/* _LINUX_IN_H */
-- 
1.5.3.7.949.g2221a6

