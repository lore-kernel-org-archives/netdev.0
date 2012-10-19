From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 21/21] sctp: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
Date: Thu, 18 Oct 2012 21:15:05 -0700
Message-ID: <1c35a1d3e2c8e20fe3dbdfa86fa156420fb3b461.1350618012.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new ipv4_addr_<foo> functions to be consistent with
the ipv6_addr_<foo> and eth_addr_<foo> style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/sctp/constants.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index d053d2e..31bae2f 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -365,12 +365,12 @@ typedef enum {
  * Also, RFC 8.4, non-unicast addresses are not considered valid SCTP
  * addresses.
  */
-#define IS_IPV4_UNUSABLE_ADDRESS(a)	    \
-	((htonl(INADDR_BROADCAST) == a) ||  \
-	 ipv4_is_multicast(a) ||	    \
-	 ipv4_is_zeronet(a) ||		    \
-	 ipv4_is_test_198(a) ||		    \
-	 ipv4_is_anycast_6to4(a))
+#define IS_IPV4_UNUSABLE_ADDRESS(a)		    \
+	((htonl(INADDR_BROADCAST) == a) ||	    \
+	 ipv4_addr_multicast(a) ||		    \
+	 ipv4_addr_zeronet(a) ||		    \
+	 ipv4_addr_test_198(a) ||		    \
+	 ipv4_addr_anycast_6to4(a))
 
 /* Flags used for the bind address copy functions.  */
 #define SCTP_ADDR6_ALLOWED	0x00000001	/* IPv6 address is allowed by
-- 
1.7.8.111.gad25c.dirty
