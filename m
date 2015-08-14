From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2] utils: add missing return value
Date: Fri, 14 Aug 2015 01:36:20 +0000
Message-ID: <1439516180-19076-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2860 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbbHNBdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 21:33:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing return value to fix warnings

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 include/utils.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/utils.h b/include/utils.h
index 95d162c..0c57ccd 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -137,7 +137,7 @@ const char *mpls_ntop(int af, const void *addr, char *str, size_t len);
 int mpls_pton(int af, const char *src, void *addr);
 
 extern int __iproute2_hz_internal;
-__get_hz(void);
+int __get_hz(void);
 
 static __inline__ int get_hz(void)
 {
-- 
1.8.3.1
