From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/7] gue: Protocol constants for remote checksum offload
Date: Sat,  1 Nov 2014 15:58:01 -0700
Message-ID: <1414882683-25484-6-git-send-email-therbert@google.com>
References: <1414882683-25484-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43553 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479AbaKAW6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 18:58:32 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so3344978iec.35
        for <netdev@vger.kernel.org>; Sat, 01 Nov 2014 15:58:32 -0700 (PDT)
In-Reply-To: <1414882683-25484-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define a private flag for remote checksun offload as well as a length
for the option.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/gue.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/gue.h b/include/net/gue.h
index cb68ae8..3f28ec7 100644
--- a/include/net/gue.h
+++ b/include/net/gue.h
@@ -59,7 +59,10 @@ struct guehdr {
 
 /* Private flags in the private option extension */
 
-#define GUE_PFLAGS_ALL	(0)
+#define GUE_PFLAG_REMCSUM	htonl(1 << 31)
+#define GUE_PLEN_REMCSUM	4
+
+#define GUE_PFLAGS_ALL	(GUE_PFLAG_REMCSUM)
 
 /* Functions to compute options length corresponding to flags.
  * If we ever have a lot of flags this can be potentially be
-- 
2.1.0.rc2.206.gedb03e5
