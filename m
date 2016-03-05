From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v3 10/12] internal.h: TRUE/FALSE macros
Date: Fri,  4 Mar 2016 16:42:11 -0800
Message-ID: <1457138533-2417-11-git-send-email-ddecotig@gmail.com>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33366 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760414AbcCEAml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 19:42:41 -0500
Received: by mail-pa0-f67.google.com with SMTP id s18so630695pal.0
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 16:42:41 -0800 (PST)
In-Reply-To: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>


Signed-off-by: David Decotigny <decot@googlers.com>
---
 internal.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/internal.h b/internal.h
index 5df8124..7c44d0e 100644
--- a/internal.h
+++ b/internal.h
@@ -42,6 +42,14 @@ typedef int32_t s32;
 #include "ethtool-copy.h"
 #include "net_tstamp-copy.h"
 
+#ifndef TRUE
+#  define TRUE 1
+#endif
+
+#ifndef FALSE
+#  define FALSE 0
+#endif
+
 #if __BYTE_ORDER == __BIG_ENDIAN
 static inline u16 cpu_to_be16(u16 value)
 {
-- 
2.7.0.rc3.207.g0ac5344
