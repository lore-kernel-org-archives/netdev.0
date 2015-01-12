From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] ipv6: directly include libc-compat.h in ipv6.h
Date: Mon, 12 Jan 2015 14:29:34 -0500
Message-ID: <1421090974-30018-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:65374 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170AbbALT3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 14:29:38 -0500
Received: by mail-yk0-f182.google.com with SMTP id 131so10061957ykp.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 11:29:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Patch 3b50d9029809 ("ipv6: fix redefinition of in6_pktinfo ...")
fixed a libc compatibility issue in ipv6 structure definitions
as described in include/uapi/linux/libc-compat.h.

It relies on including linux/in6.h to include libc-compat.h itself.
Include that file directly to clearly communicate the dependency
(libc-compat.h: "This include must be as early as possible").

Signed-off-by: Willem de Bruijn <willemb@google.com>

----

As discussed in http://patchwork.ozlabs.org/patch/427384/
---
 include/uapi/linux/ipv6.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index b9b1b7d..73cb02d 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -1,6 +1,7 @@
 #ifndef _UAPI_IPV6_H
 #define _UAPI_IPV6_H
 
+#include <linux/libc-compat.h>
 #include <linux/types.h>
 #include <linux/in6.h>
 #include <asm/byteorder.h>
-- 
2.2.0.rc0.207.ga3a616c
