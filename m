From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] Do not strip binaries with `install`
Date: Sun, 16 Mar 2008 04:27:01 -0400
Message-ID: <1205656021-26124-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46451 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751176AbYCPIZy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Mar 2008 04:25:54 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 ip/Makefile   |    2 +-
 misc/Makefile |    2 +-
 tc/Makefile   |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/ip/Makefile b/ip/Makefile
index d908817..73978ff 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -17,7 +17,7 @@ ip: $(IPOBJ) $(LIBNETLINK) $(LIBUTIL)
 rtmon: $(RTMONOBJ) $(LIBNETLINK)
 
 install: all
-	install -m 0755 -s $(TARGETS) $(DESTDIR)$(SBINDIR)
+	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
 	install -m 0755 $(SCRIPTS) $(DESTDIR)$(SBINDIR)
 
 clean:
diff --git a/misc/Makefile b/misc/Makefile
index bda37e5..8c25381 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -27,7 +27,7 @@ ssfilter.c: ssfilter.y
 lnstat: $(LNSTATOBJ)
 
 install: all
-	install -m 0755 -s $(TARGETS) $(DESTDIR)$(SBINDIR)
+	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
 	ln -sf lnstat $(DESTDIR)$(SBINDIR)/rtstat
 	ln -sf lnstat $(DESTDIR)$(SBINDIR)/ctstat
 
diff --git a/tc/Makefile b/tc/Makefile
index 7ece958..bf2df00 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -73,9 +73,9 @@ libtc.a: $(TCLIB)
 
 install: all
 	mkdir -p $(DESTDIR)/usr/lib/tc
-	install -m 0755 -s tc $(DESTDIR)$(SBINDIR)
+	install -m 0755 tc $(DESTDIR)$(SBINDIR)
 	for i in $(TCSO); \
-	do install -m 755 -s $$i $(DESTDIR)/usr/lib/tc; \
+	do install -m 755 $$i $(DESTDIR)/usr/lib/tc; \
 	done
 
 clean:
-- 
1.5.4.3

