From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] tc: respect LDFLAGS for %.so targets
Date: Sat, 26 Dec 2009 14:52:36 -0500
Message-ID: <1261857156-9037-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:44566 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbZLZTwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:52:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since there aren't any targets that currently use this pattern rule, this
is more of a proactive fix.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tc/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/Makefile b/tc/Makefile
index f3dd2b7..0b5d7d3 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -87,7 +87,7 @@ YACC := bison
 LEX := flex
 
 %.so: %.c
-	$(CC) $(CFLAGS) -shared -fpic $< -o $@
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
 
 
 all: libtc.a tc $(TCSO)
-- 
1.6.6.rc4

