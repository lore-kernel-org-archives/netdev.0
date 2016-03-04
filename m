From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 09/12] internal.h: fix build for latest ethtool-copy.h
Date: Thu,  3 Mar 2016 20:23:22 -0800
Message-ID: <1457065405-19049-10-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34121 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757727AbcCDEXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:48 -0500
Received: by mail-pa0-f66.google.com with SMTP id hj7so2395837pac.1
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:48 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>


Signed-off-by: David Decotigny <decot@googlers.com>
---
 internal.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/internal.h b/internal.h
index 5f8504d..5df8124 100644
--- a/internal.h
+++ b/internal.h
@@ -13,6 +13,7 @@
 #ifdef HAVE_CONFIG_H
 #include "ethtool-config.h"
 #endif
+#include <limits.h>
 #include <stdio.h>
 #include <stdint.h>
 #include <stdlib.h>
@@ -36,6 +37,8 @@ typedef uint16_t u16;
 typedef uint8_t u8;
 typedef int32_t s32;
 
+#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
+
 #include "ethtool-copy.h"
 #include "net_tstamp-copy.h"
 
@@ -72,7 +75,6 @@ static inline u64 cpu_to_be64(u64 value)
 
 #define BITS_PER_BYTE		8
 #define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
-#define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
 #define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
 
 static inline void set_bit(unsigned int nr, unsigned long *addr)
-- 
2.7.0.rc3.207.g0ac5344
