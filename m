From: sfeldma@gmail.com
Subject: [PATCH net-next v4 16/24] bonding: cut over to new swdev_port_bridge_dellink
Date: Sun, 12 Apr 2015 23:17:10 -0700
Message-ID: <1428905838-14920-17-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36634 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbbDMGQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:50 -0400
Received: by pabsx10 with SMTP id sx10so91885344pab.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:49 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ef5207c..83c02de 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4038,7 +4038,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
 	.ndo_bridge_setlink	= swdev_port_bridge_setlink,
-	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
+	.ndo_bridge_dellink	= swdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
 
-- 
1.7.10.4
