From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 10/12] internal.h: TRUE/FALSE macros
Date: Thu,  3 Mar 2016 20:23:23 -0800
Message-ID: <1457065405-19049-11-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35963 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757734AbcCDEXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:49 -0500
Received: by mail-pf0-f194.google.com with SMTP id q129so2495552pfb.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:48 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>


Signed-off-by: David Decotigny <decot@googlers.com>
---
 internal.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/internal.h b/internal.h
index 5df8124..5fd87f1 100644
--- a/internal.h
+++ b/internal.h
@@ -42,6 +42,14 @@ typedef int32_t s32;
 #include "ethtool-copy.h"
 #include "net_tstamp-copy.h"
 
+#ifndef TRUE
+#  define TRUE (!0)
+#endif
+
+#ifndef FALSE
+#  define FALSE (!!0)
+#endif
+
 #if __BYTE_ORDER == __BIG_ENDIAN
 static inline u16 cpu_to_be16(u16 value)
 {
-- 
2.7.0.rc3.207.g0ac5344
