From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 3/3] kernel: remove HIPQUAD()
Date: Sat, 28 Mar 2009 18:38:31 -0700
Message-ID: <1238290711.3492.10.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:54282 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbZC2Biq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 21:38:46 -0400
Received: by wf-out-1314.google.com with SMTP id 29so1991049wff.4
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2009 18:38:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users have been removed.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 include/linux/kernel.h |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 914918a..f81d80f 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -379,18 +379,6 @@ static inline char *pack_hex_byte(char *buf, u8 byte)
 	((unsigned char *)&addr)[3]
 #define NIPQUAD_FMT "%u.%u.%u.%u"
 
-#if defined(__LITTLE_ENDIAN)
-#define HIPQUAD(addr) \
-	((unsigned char *)&addr)[3], \
-	((unsigned char *)&addr)[2], \
-	((unsigned char *)&addr)[1], \
-	((unsigned char *)&addr)[0]
-#elif defined(__BIG_ENDIAN)
-#define HIPQUAD	NIPQUAD
-#else
-#error "Please fix asm/byteorder.h"
-#endif /* __LITTLE_ENDIAN */
-
 /*
  * min()/max()/clamp() macros that also do
  * strict type-checking.. See the
-- 
1.6.2.1.507.g0e68d

