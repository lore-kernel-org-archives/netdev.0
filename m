From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [PATCH iputils] iputils: use syntax compatible with busybox date in Makefile
Date: Fri,  3 Oct 2014 23:49:49 +0300
Message-ID: <1412369389-21815-1-git-send-email-aaro.koskinen@iki.fi>
Cc: netdev@vger.kernel.org, Aaro Koskinen <aaro.koskinen@iki.fi>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	David Heidelberger <david.heidelberger@ixit.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from filtteri1.pp.htv.fi ([213.243.153.184]:51150 "EHLO
	filtteri1.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaJCU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use syntax compatible with busybox date in Makefile. This fixes an error
message during the build under busybox.

Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
---
 Makefile | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/Makefile b/Makefile
index 54e5a6d..f5f1101 100644
--- a/Makefile
+++ b/Makefile
@@ -115,9 +115,9 @@ LDLIBS=$(LDLIB) $(ADDLIB)
 
 UNAME_N:=$(shell uname -n)
 LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
-TODAY=$(shell date +%Y/%m/%d)
-DATE=$(shell date --date $(TODAY) +%Y%m%d)
-TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)
+TODAY=$(shell date +%Y-%m-%d)
+DATE=$(shell date -d $(TODAY) +%Y%m%d)
+TAG:=$(shell date -d $(TODAY) +s%Y%m%d)
 
 
 # -------------------------------------
-- 
2.1.2
