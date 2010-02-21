From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] gianfar: add brace at gfar_netpoll()
Date: Sun, 21 Feb 2010 04:17:39 +0300
Message-ID: <1266715059-18682-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:37426 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755608Ab0BUBRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Feb 2010 20:17:52 -0500
Received: by fxm19 with SMTP id 19so1328938fxm.21
        for <netdev@vger.kernel.org>; Sat, 20 Feb 2010 17:17:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found by cppcheck.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/gianfar.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 16def13..6850dc0 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2644,6 +2644,7 @@ static void gfar_netpoll(struct net_device *dev)
 			gfar_interrupt(priv->gfargrp[i].interruptTransmit,
 						&priv->gfargrp[i]);
 			enable_irq(priv->gfargrp[i].interruptTransmit);
+		}
 	}
 }
 #endif
-- 
1.7.0

