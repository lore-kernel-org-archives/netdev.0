From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 2/3] tlan: Fix partner capability printout
Date: Thu,  6 Jan 2011 20:50:16 +0200
Message-ID: <1294339817-31434-2-git-send-email-sakari.ailus@iki.fi>
References: <4D260ED0.5040301@iki.fi>
 <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:52983 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab1AFS7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:59:12 -0500
Received: from hillosipuli.localdomain (nblzone-211-213.nblnetworks.fi [83.145.211.213])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-68.nebula.fi (Postfix) with ESMTP id A3E6D43F0B34
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:20 +0200 (EET)
Received: from retiisi.localdomain (unknown [192.168.3.254])
	by hillosipuli.localdomain (Postfix) with ESMTP id D12916009C
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:16 +0200 (EET)
Received: from masiina.localdomain (masiina.localdomain [192.168.1.1])
	by retiisi.localdomain (Postfix) with ESMTP id 6759220E41
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:17 +0200 (EET)
Received: from masiina.localdomain (localhost [127.0.0.1])
	by masiina.localdomain (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id p06IoH8r031474
	for <netdev@vger.kernel.org>; Thu, 6 Jan 2011 20:50:17 +0200
Received: (from sakke@localhost)
	by masiina.localdomain (8.14.3/8.14.3/Submit) id p06IoHFY031473
	for netdev@vger.kernel.org; Thu, 6 Jan 2011 20:50:17 +0200
In-Reply-To: <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix partner capability printout. Add spaces and do not print null.

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 57380b1..090ce21 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -2367,10 +2367,10 @@ tlan_finish_reset(struct net_device *dev)
 					? "" : "0",
 					tlphy_par & TLAN_PHY_DUPLEX_FULL
 					? "Full" : "half");
-				pr_info("TLAN: Partner capability: ");
-				for (i = 5; i <= 10; i++)
+				pr_info("TLAN: Partner capability:");
+				for (i = 5; i < 10; i++)
 					if (partner & (1<<i))
-						printk("%s", media[i-5]);
+						printk(" %s", media[i-5]);
 				printk("\n");
 			}
 
-- 
1.5.6.5

