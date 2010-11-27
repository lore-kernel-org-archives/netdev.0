From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 5/6] forcedeth: use KERN_ facility level in printk
Date: Sat, 27 Nov 2010 19:39:47 +0100
Message-ID: <1290883188-2078-6-git-send-email-szymon@janc.net.pl>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56864 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753235Ab0K0SvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:02 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id C8B5680153CD
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:51 +0100 (CET)
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Szymon Janc <szymon@janc.net.pl>
---
 drivers/net/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 2f092d7..a2b6681 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -958,7 +958,7 @@ static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
 		delaymax -= delay;
 		if (delaymax < 0) {
 			if (msg)
-				printk("%s", msg);
+				printk(KERN_WARNING "%s", msg);
 			return 1;
 		}
 	} while ((readl(base + offset) & mask) != target);
-- 
1.7.2.3


