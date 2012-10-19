From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH 1/1] [PATCH net-next] net:dev: remove double indentical assignment in dev_change_net_namespace().
Date: Fri, 19 Oct 2012 13:09:30 +0200
Message-ID: <1350644970-2877-1-git-send-email-ramirose@gmail.com>
Cc: serge.hallyn@canonical.com, Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:48549 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753704Ab2JSJKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 05:10:04 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so3133992wib.1
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 02:10:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes double assignment of err to -EINVAL in dev_change_net_namespace().

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 net/core/dev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 09cb3f6..b4978e2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6264,7 +6264,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 		goto out;
 
 	/* Ensure the device has been registrered */
-	err = -EINVAL;
 	if (dev->reg_state != NETREG_REGISTERED)
 		goto out;
 
-- 
1.7.11.4
