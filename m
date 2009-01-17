From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] tc/q_atm.so: respect LDFLAGS
Date: Sat, 17 Jan 2009 12:07:27 -0500
Message-ID: <1232212047-25151-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53367 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760940AbZAQRH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jan 2009 12:07:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The q_atm.so target defines its own link target, but it doesn't respect the
$(LDFLAGS) variable.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tc/Makefile |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/Makefile b/tc/Makefile
index bd9b833..2a28363 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -86,7 +86,7 @@ clean:
 	rm -f emp_ematch.yacc.output
 
 q_atm.so: q_atm.c
-	$(CC) $(CFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
 %.yacc.c: %.y
 	$(YACC) $(YACCFLAGS) -o $@ $<
-- 
1.6.1

