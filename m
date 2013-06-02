From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 2/3] net: do not manually initialize enumerators
Date: Sat,  1 Jun 2013 20:23:16 -0600
Message-ID: <1370139797-8912-2-git-send-email-sakiwit@gmail.com>
References: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:41040 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab3FBCYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 22:24:49 -0400
Received: by mail-ie0-f181.google.com with SMTP id x14so7495128ief.12
        for <netdev@vger.kernel.org>; Sat, 01 Jun 2013 19:24:48 -0700 (PDT)
In-Reply-To: <1370139797-8912-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up unnecessary initialization of enumerators as the compiler takes
care of that.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 include/linux/net.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 99c9f0c..4f27575 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -79,9 +79,9 @@ enum sock_type {
 #endif /* ARCH_HAS_SOCKET_TYPES */
 
 enum sock_shutdown_cmd {
-	SHUT_RD		= 0,
-	SHUT_WR		= 1,
-	SHUT_RDWR	= 2,
+	SHUT_RD,
+	SHUT_WR,
+	SHUT_RDWR,
 };
 
 struct socket_wq {
