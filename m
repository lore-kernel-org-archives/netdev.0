From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/3] lib: include the Config file too
Date: Sun, 16 Dec 2012 17:09:16 -0500
Message-ID: <1355695757-9957-2-git-send-email-vapier@gentoo.org>
References: <1355695757-9957-1-git-send-email-vapier@gentoo.org>
Cc: jengelh@inai.de
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58781 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154Ab2LPWJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2012 17:09:18 -0500
In-Reply-To: <1355695757-9957-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lib makefile doesn't include Config which means it misses
setting up toolchain vars that it includes.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 lib/Makefile | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/Makefile b/lib/Makefile
index bfbe672..a42b885 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,3 +1,5 @@
+include ../Config
+
 CFLAGS += -fPIC
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
-- 
1.8.0
