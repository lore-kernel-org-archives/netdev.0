From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next-2.6] cpmac: fix compilation failure introduced with netdev_ops conversion
Date: Wed, 24 Jun 2009 14:24:48 +0200
Message-ID: <200906241424.48699.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:49823 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbZFXMYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 08:24:49 -0400
Received: by ewy6 with SMTP id 6so1106801ewy.37
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 05:24:51 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes and obvious typo in the netdev_ops initialization:
ndo_so_ioctl should be ndo_do_ioctl.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 58afafb..fd5e32c 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -1097,7 +1097,7 @@ static const struct net_device_ops cpmac_netdev_ops = {
 	.ndo_start_xmit		= cpmac_start_xmit,
 	.ndo_tx_timeout		= cpmac_tx_timeout,
 	.ndo_set_multicast_list	= cpmac_set_multicast_list,
-	.ndo_so_ioctl		= cpmac_ioctl,
+	.ndo_do_ioctl		= cpmac_ioctl,
 	.ndo_set_config		= cpmac_config,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
