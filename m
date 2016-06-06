From: Colin King <colin.king@canonical.com>
Subject: [PATCH][RESEND] gtp: #define _UAPI_LINUX_GTP_H_ and not _UAPI_LINUX_GTP_H__
Date: Mon,  6 Jun 2016 16:08:41 +0100
Message-ID: <1465225721-16371-1-git-send-email-colin.king@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35165 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbcFFPIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 11:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Fix clang build warning:

./include/uapi/linux/gtp.h:1:9: warning: '_UAPI_LINUX_GTP_H_' is
used as a header guard here, followed by #define of a different
macro [-Wheader-guard]

fix by defining  _UAPI_LINUX_GTP_H_ and not _UAPI_LINUX_GTP_H__

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 include/uapi/linux/gtp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index ca1054d..72a04a0 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -1,5 +1,5 @@
 #ifndef _UAPI_LINUX_GTP_H_
-#define _UAPI_LINUX_GTP_H__
+#define _UAPI_LINUX_GTP_H_
 
 enum gtp_genl_cmds {
 	GTP_CMD_NEWPDP,
-- 
2.8.1
