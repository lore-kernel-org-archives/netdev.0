From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/14] nfp: remove unnecessary call to ether_setup()
Date: Mon, 31 Oct 2016 20:43:11 +0000
Message-ID: <1477946602-19644-4-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36045 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030363AbcJaUoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:01 -0400
Received: by mail-wm0-f53.google.com with SMTP id p190so170354752wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:01 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ether_setup() will be invoked by alloc_etherdev_mqs(), no need
to call it again.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 4e4b6e3b30d7..bd28e42bee2b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2839,7 +2839,6 @@ int nfp_net_netdev_init(struct net_device *netdev)
 		return err;
 
 	/* Finalise the netdev setup */
-	ether_setup(netdev);
 	netdev->netdev_ops = &nfp_net_netdev_ops;
 	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
 
-- 
1.9.1
