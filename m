From: Guillaume Gomez <guillaume1.gomez@gmail.com>
Subject: [PATCH] net: Remove unneeded return from void function
Date: Wed, 23 Sep 2015 12:31:27 +0200
Message-ID: <CAAOQCfQr9V-mb5uJdxk_=Npuy+Fx1ekAFoC2t-bWZJCqfLqmdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35815 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbbIWKb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 06:31:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Guillaume Gomez <guillaume1.gomez@gmail.com>
---
 include/linux/netdevice.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88a0069..4a444a1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -457,7 +457,7 @@ void napi_complete_done(struct napi_struct *n, int
work_done);
  */
 static inline void napi_complete(struct napi_struct *n)
 {
-    return napi_complete_done(n, 0);
+    napi_complete_done(n, 0);
 }

 /**
-- 
2.1.4
