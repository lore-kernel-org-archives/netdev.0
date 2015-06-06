From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] rhashtable: add missing import <linux/export.h>
Date: Sat,  6 Jun 2015 22:07:23 +0200
Message-ID: <1433621243-30976-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: tgraf@suug.ch, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:37123 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893AbbFFUHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2015 16:07:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rhashtable uses EXPORT_SYMBOL_GPL() without importing linux/export.h
directly it is only imported indirectly through some other includes.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 lib/rhashtable.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index b28df40..1b70b49 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -25,6 +25,7 @@
 #include <linux/random.h>
 #include <linux/rhashtable.h>
 #include <linux/err.h>
+#include <linux/export.h>
 
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4U
-- 
2.1.4
