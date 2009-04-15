From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH -next 1/3] ipw2x00: remove old compat_net_dev_ops code
Date: Wed, 15 Apr 2009 21:58:27 +0400
Message-ID: <1239818309-14899-1-git-send-email-a.beregalov@gmail.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:29635 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZDOR6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 13:58:45 -0400
Received: by ti-out-0910.google.com with SMTP id 11so6496tim.23
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 10:58:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since both ipw2100 and ipw2200 are already converted to new
net_device_ops this code is useless.

Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---
 drivers/net/wireless/ipw2x00/libipw_module.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/libipw_module.c b/drivers/net/wireless/ipw2x00/libipw_module.c
index 92a2692..8ce6e96 100644
--- a/drivers/net/wireless/ipw2x00/libipw_module.c
+++ b/drivers/net/wireless/ipw2x00/libipw_module.c
@@ -154,10 +154,6 @@ struct net_device *alloc_ieee80211(int sizeof_priv)
 		goto failed;
 	}
 	ieee = netdev_priv(dev);
-#ifdef CONFIG_COMPAT_NET_DEV_OPS
-	dev->hard_start_xmit = ieee80211_xmit;
-	dev->change_mtu = ieee80211_change_mtu;
-#endif
 
 	ieee->dev = dev;
 
-- 
1.6.2.3

