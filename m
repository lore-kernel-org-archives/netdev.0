From: Colin King <colin.king@canonical.com>
Subject: [PATCH] gtp: #define #define _GTP_H_ and not #define _GTP_H
Date: Sun, 24 Jul 2016 19:24:09 +0100
Message-ID: <1469384649-11556-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41065 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbcGXSZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2016 14:25:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Fix clang build warning:

./include/net/gtp.h:1:9: warning: '_GTP_H_' is used as a header
guard here, followed by #define of a different macro [-Wheader-guard]

fix by defining _GTP_H_ and not _GTP_H

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 include/net/gtp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/gtp.h b/include/net/gtp.h
index 894a37b..6398891 100644
--- a/include/net/gtp.h
+++ b/include/net/gtp.h
@@ -1,5 +1,5 @@
 #ifndef _GTP_H_
-#define _GTP_H
+#define _GTP_H_
 
 /* General GTP protocol related definitions. */
 
-- 
2.8.1
