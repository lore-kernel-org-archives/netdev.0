From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCH iproute2] tipc: make build conditional on having libmnl
Date: Sat, 27 Jun 2015 07:25:28 -0300
Message-ID: <1435400728-13012-1-git-send-email-gustavo@zacarias.com.ar>
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:39475 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbbF0KZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 06:25:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 Makefile | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/Makefile b/Makefile
index 67176be..8153445 100644
--- a/Makefile
+++ b/Makefile
@@ -41,7 +41,11 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
 YACCFLAGS = -d -t -v
 
-SUBDIRS=lib ip tc bridge misc netem genl tipc man
+SUBDIRS=lib ip tc bridge misc netem genl man
+
+ifeq ($(HAVE_MNL),y)
+SUBDIRS += tipc
+endif
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
-- 
2.3.6
