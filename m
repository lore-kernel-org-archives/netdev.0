From: Kylie McClain <somasissounds@gmail.com>
Subject: [PATCH] ipaddress: fix build with musl libc
Date: Sun, 22 May 2016 19:52:02 -0400
Message-ID: <1463961122-5943-1-git-send-email-somasis@exherbo.org>
Cc: Kylie McClain <somasis@exherbo.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:33286 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbcEWDwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 23:52:08 -0400
Received: by mail-qg0-f67.google.com with SMTP id 90so14044140qgz.0
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 20:52:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MIN() is defined within sys/param.h.

Signed-off-by: Kylie McClain <somasis@exherbo.org>
---
 ip/ipaddress.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 0692fba..df363b0 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -19,6 +19,7 @@
 #include <sys/ioctl.h>
 #include <sys/socket.h>
 #include <sys/ioctl.h>
+#include <sys/param.h>
 #include <errno.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
-- 
2.8.2
