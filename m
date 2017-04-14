From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] hv_netvsc: change netvsc device default duplex to FULL
Date: Fri, 14 Apr 2017 14:42:58 -0700
Message-ID: <20170414214258.3367-2-sthemmin@microsoft.com>
References: <20170414214258.3367-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Simon Xiao <sixiao@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:36046 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752705AbdDNVnC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 17:43:02 -0400
Received: by mail-pf0-f180.google.com with SMTP id 194so5509992pfv.3
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 14:43:02 -0700 (PDT)
In-Reply-To: <20170414214258.3367-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Xiao <sixiao@microsoft.com>

The netvsc device supports full duplex by default.
This warnings in log from bonding device which did not like
seeing UNKNOWN duplex.

Signed-off-by: Simon Xiao <sixiao@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 76489a06ef3b..fad5a57765b9 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -815,7 +815,7 @@ static void netvsc_init_settings(struct net_device *dev)
 	struct net_device_context *ndc = netdev_priv(dev);
 
 	ndc->speed = SPEED_UNKNOWN;
-	ndc->duplex = DUPLEX_UNKNOWN;
+	ndc->duplex = DUPLEX_FULL;
 }
 
 static int netvsc_get_link_ksettings(struct net_device *dev,
-- 
2.11.0
