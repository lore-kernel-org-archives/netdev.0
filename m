From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 1/2] [IPROUTE2] Add missing LIBUTIL for dependencies.
Date: Tue, 11 Sep 2007 16:02:34 -0400
Message-ID: <11895409553082-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:53474 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934309AbXIKUDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 16:03:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: John Heffner <jheffner@psc.edu>
---
 Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index af0d5e4..7e4605c 100644
--- a/Makefile
+++ b/Makefile
@@ -29,7 +29,8 @@ LDLIBS += -L../lib -lnetlink -lutil
 
 SUBDIRS=lib ip tc misc netem genl
 
-LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
+LIBUTIL=../lib/libutil.a
+LIBNETLINK=../lib/libnetlink.a $(LIBUTIL)
 
 all: Config
 	@set -e; \
-- 
1.5.3.rc4.29.g74276-dirty

