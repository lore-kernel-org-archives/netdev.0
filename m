From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH] gianfar: Fix misleading indentation in startup_gfar()
Date: Tue, 18 Jan 2011 15:36:02 +0300
Message-ID: <20110118123602.GA26997@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33146 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab1ARMgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 07:36:07 -0500
Received: by ewy5 with SMTP id 5so3192523ewy.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 04:36:05 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just stumbled upon the issue while looking for another bug.

The code looks correct, the indentation is not.

Signed-off-by: Anton Vorontsov <cbouatmailru@gmail.com>
---
 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 119aa20..5ed8f9f 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1920,7 +1920,7 @@ int startup_gfar(struct net_device *ndev)
 		if (err) {
 			for (j = 0; j < i; j++)
 				free_grp_irqs(&priv->gfargrp[j]);
-				goto irq_fail;
+			goto irq_fail;
 		}
 	}
 
-- 
1.7.0.5
