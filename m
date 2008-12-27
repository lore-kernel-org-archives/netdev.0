From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH] Makefile: disable sparse warning "returning void-valued expression"
Date: Sat, 27 Dec 2008 22:38:44 +0100
Message-ID: <4956a360.0b38560a.3c6c.ffff9113@mx.google.com>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	    <20081222191517.11807.20718.stgit@vmbox.hanneseder.net>
	    <20081225.161740.10052019.davem@davemloft.net>
	    <20081226115921.bb094c58.rdunlap@xenotime.net>
	    <49567dd3.0b38560a.3c6c.0511@mx.google.com>
	    <20081227192012.GB10592@uranus.ravnborg.org>
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:64261 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbYL0Vvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2008 16:51:31 -0500
In-Reply-To: <20081227192012.GB10592@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sparse warning -Wreturn-void ("returning void-valued expression")
is off by default, but it is enabled with -Wall, so add
-Wno-return-void to CHECKFLAGS to disable it.

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 64f14aa..a5b5e8d 100644
--- a/Makefile
+++ b/Makefile
@@ -321,7 +321,8 @@ KALLSYMS	= scripts/kallsyms
 PERL		= perl
 CHECK		= sparse
 
-CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ -Wbitwise $(CF)
+CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ \
+		  -Wbitwise -Wno-return-void $(CF)
 MODFLAGS	= -DMODULE
 CFLAGS_MODULE   = $(MODFLAGS)
 AFLAGS_MODULE   = $(MODFLAGS)
