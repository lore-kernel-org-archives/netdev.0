From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 3/4] bgmac: add generic ndo_validate_addr netdev ops
Date: Wed,  6 Feb 2013 15:44:59 +0100
Message-ID: <1360161900-2330-4-git-send-email-hauke@hauke-m.de>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34674 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab3BFOpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 09:45:21 -0500
In-Reply-To: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index c0152396..e0775c4 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1210,6 +1210,7 @@ static const struct net_device_ops bgmac_netdev_ops = {
 	.ndo_stop		= bgmac_stop,
 	.ndo_start_xmit		= bgmac_start_xmit,
 	.ndo_set_mac_address	= bgmac_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_do_ioctl           = bgmac_ioctl,
 };
 
-- 
1.7.10.4
