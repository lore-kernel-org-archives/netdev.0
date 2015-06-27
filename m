From: Gustavo Zacarias <gustavo@zacarias.com.ar>
Subject: [PATCHv2 iproute2] tipc: make build conditional on having libmnl
Date: Sat, 27 Jun 2015 08:15:50 -0300
Message-ID: <1435403751-17245-1-git-send-email-gustavo@zacarias.com.ar>
Cc: Gustavo Zacarias <gustavo@zacarias.com.ar>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.zacarias.com.ar ([176.9.42.171]:39869 "EHLO
	www.zacarias.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbbF0LQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 07:16:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
---
 tipc/Makefile | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tipc/Makefile b/tipc/Makefile
index 4bda8c5..b3ef9b9 100644
--- a/tipc/Makefile
+++ b/tipc/Makefile
@@ -1,3 +1,6 @@
+include ../Config
+ifeq ($(HAVE_MNL),y)
+
 TIPCOBJ=bearer.o \
     cmdl.o link.o \
     media.o misc.o \
@@ -8,6 +11,8 @@ TIPCOBJ=bearer.o \
 TARGETS=tipc
 LDLIBS += -lmnl
 
+endif
+
 all: $(TARGETS) $(LIBS)
 
 tipc: $(TIPCOBJ)
-- 
2.3.6
