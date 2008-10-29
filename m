From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 4/4] printk: remove %p6 format specifier, fix up comments
Date: Wed, 29 Oct 2008 11:35:42 -0700
Message-ID: <1225305342.5688.39.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:23742 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbYJ2Slg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 14:41:36 -0400
Received: by wf-out-1314.google.com with SMTP id 27so129583wfd.4
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 11:41:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 lib/vsprintf.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index a863006..dd7cc7f 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -649,9 +649,7 @@ static char *ip4_addr_string(char *buf, char *end, u8 *addr, int field_width,
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way (dot-separated
  *       decimal for v4 and colon separated network-order 16 bit hex for v6)
  * - 'i' [46] for 'raw' IPv4/IPv6 addresses, IPv6 omits the colons, IPv4 is
-         currently the same
- * - '6' For a IPv6 address prints the address in network-ordered 16 bit hex
- *       with colon separators
+ *       currently the same
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -669,8 +667,6 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr, int field
 		return resource_string(buf, end, ptr, field_width, precision, flags);
 	case 'M':
 		return mac_address_string(buf, end, ptr, field_width, precision, flags);
-	case '6':
-		return ip6_addr_string(buf, end, ptr, field_width, precision, flags);
 	case 'i':
 		flags |= SPECIAL;
 		/* Fallthrough */
-- 
1.6.0.3.756.gb776d

