From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH iproute2] ipaddress: needs to include <sys/param.h>
Date: Thu, 19 May 2016 14:29:46 -0300
Message-ID: <1463678986-3732-1-git-send-email-gustavo@zacarias.com.ar>
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:51952 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342AbcESRkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 13:40:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's using MIN() now, otherwise it breaks for musl libc.

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
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
2.7.3
