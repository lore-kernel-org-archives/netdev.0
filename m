From: Joe Perches <joe@perches.com>
Subject: [PATCH 21/21] drivers/net/tlan.h: Convert printk(KERN_DEBUG to pr_dbg(
Date: Sun,  4 Oct 2009 17:53:48 -0700
Message-ID: <29c66ee0bae26a0c352b4605e3f1fcbe0612f3a5.1254701151.git.joe@perches.com>
References: <cover.1254701151.git.joe@perches.com>
Cc: Samuel Chessman <chessman@tux.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1747 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758343AbZJEAz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Oct 2009 20:55:59 -0400
In-Reply-To: <cover.1254701151.git.joe@perches.com>
In-Reply-To: <cover.1254701151.git.joe@perches.com>
References: <cover.1254701151.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed "TLAN: " prefix from debug printks, it's added by pr_fmt

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tlan.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tlan.h b/drivers/net/tlan.h
index 4b82f28..c5a4ad5 100644
--- a/drivers/net/tlan.h
+++ b/drivers/net/tlan.h
@@ -44,7 +44,7 @@
 #define TLAN_RECORD		1
 
 #define TLAN_DBG(lvl, format, args...)	\
-	do { if (debug&lvl) printk(KERN_DEBUG "TLAN: " format, ##args ); } while(0)
+	do { if (debug & lvl) pr_dbg(format, ##args); } while (0)
 
 #define TLAN_DEBUG_GNRL		0x0001
 #define TLAN_DEBUG_TX		0x0002
-- 
1.6.3.1.10.g659a0.dirty

