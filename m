From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 2/2] net: uapi: do not manually set the first enumerator to zero
Date: Sun, 23 Jun 2013 15:56:17 -0600
Message-ID: <1372024577-6343-2-git-send-email-sakiwit@gmail.com>
References: <1372024577-6343-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42356 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab3FWV6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 17:58:00 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp12so10067095pab.21
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 14:57:59 -0700 (PDT)
In-Reply-To: <1372024577-6343-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up the unnecessary assignment of the first enumerator to zero.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 include/uapi/linux/net.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/net.h b/include/uapi/linux/net.h
index 9136b54..9177fd3 100644
--- a/include/uapi/linux/net.h
+++ b/include/uapi/linux/net.h
@@ -48,7 +48,7 @@ enum {
 };
 
 typedef enum {
-	SS_FREE = 0,			/* not allocated		*/
+	SS_FREE,			/* not allocated		*/
 	SS_UNCONNECTED,			/* unconnected to any socket	*/
 	SS_CONNECTING,			/* in process of connecting	*/
 	SS_CONNECTED,			/* connected to socket		*/
