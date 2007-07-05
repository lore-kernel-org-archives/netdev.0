From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/core/netevent.c should #include <net/netevent.h>
Date: Fri, 6 Jul 2007 01:22:17 +0200
Message-ID: <20070705232217.GS3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:52115 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761073AbXGEXVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:21:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every file should include the headers containing the prototypes for
its global functions.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/net/core/netevent.c.old	2007-07-03 04:59:08.000000000 +0200
+++ linux-2.6.22-rc6-mm1/net/core/netevent.c	2007-07-03 04:59:23.000000000 +0200
@@ -15,6 +15,7 @@
 
 #include <linux/rtnetlink.h>
 #include <linux/notifier.h>
+#include <net/netevent.h>
 
 static ATOMIC_NOTIFIER_HEAD(netevent_notif_chain);
 

