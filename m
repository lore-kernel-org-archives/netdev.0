From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: [PATCH] libbridge: use CFLAGS provided via configure script
Date: Tue, 24 Jun 2014 17:52:09 +0200
Message-ID: <1403625129-4220-1-git-send-email-yegorslists@googlemail.com>
Cc: shemminger@vyatta.com, Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:55049 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394AbaFXPwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:52:31 -0400
Received: by mail-wi0-f173.google.com with SMTP id cc10so6216816wib.12
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:52:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
 libbridge/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libbridge/Makefile.in b/libbridge/Makefile.in
index 20512c4..924f750 100644
--- a/libbridge/Makefile.in
+++ b/libbridge/Makefile.in
@@ -5,7 +5,7 @@ AR=ar
 RANLIB=@RANLIB@
 
 CC=@CC@
-CFLAGS = -Wall -g $(KERNEL_HEADERS)
+CFLAGS = -Wall -g @CFLAGS@ $(KERNEL_HEADERS)
 
 prefix=@prefix@
 exec_prefix=@exec_prefix@
-- 
1.8.3.2
