From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: [PATCH v2] libbridge: use CFLAGS provided via configure script
Date: Tue, 24 Jun 2014 21:32:11 +0200
Message-ID: <1403638331-16760-1-git-send-email-yegorslists@googlemail.com>
Cc: shemminger@vyatta.com, Yegor Yefremov <yegorslists@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:52326 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbaFXTca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 15:32:30 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so6591576wib.5
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 12:32:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
---
Changes:
	v2: remove '-g'

 libbridge/Makefile.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/libbridge/Makefile.in b/libbridge/Makefile.in
index 20512c4..7932bfe 100644
--- a/libbridge/Makefile.in
+++ b/libbridge/Makefile.in
@@ -5,7 +5,7 @@ AR=ar
 RANLIB=@RANLIB@
 
 CC=@CC@
-CFLAGS = -Wall -g $(KERNEL_HEADERS)
+CFLAGS = -Wall @CFLAGS@ $(KERNEL_HEADERS)
 
 prefix=@prefix@
 exec_prefix=@exec_prefix@
-- 
1.8.3.2
