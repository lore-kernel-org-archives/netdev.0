From: Szymon Janc <szymon@janc.net.pl>
Subject: [PATCH 3/6] forcedeth: include <linux/io.h> and <linux/uaccess.h> instead of <asm/io.h> and <asm/uaccess.h> as suggested by checkpatch
Date: Sat, 27 Nov 2010 19:39:45 +0100
Message-ID: <1290883188-2078-4-git-send-email-szymon@janc.net.pl>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Cc: Szymon Janc <szymon@janc.net.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cox.rootnode.net ([89.248.165.14]:56866 "EHLO cox.rootnode.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753094Ab0K0SvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 13:51:01 -0500
Received: from DSPAM-Daemon (localhost [127.0.0.1])
	by cox.rootnode.net (Postfix) with SMTP id 88EAB801543B
	for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 19:41:50 +0100 (CET)
In-Reply-To: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Szymon Janc <szymon@janc.net.pl>
---
 drivers/net/forcedeth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 81722fb..8deae90 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -60,10 +60,10 @@
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
 #include <linux/slab.h>
+#include <linux/uaccess.h>
+#include  <linux/io.h>
 
 #include <asm/irq.h>
-#include <asm/io.h>
-#include <asm/uaccess.h>
 #include <asm/system.h>
 
 #if 0
-- 
1.7.2.3


