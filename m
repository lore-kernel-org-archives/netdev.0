From: sfeldma@gmail.com
Subject: [PATCH net-next v4 15/24] rocker: cut over to new swdev_port_bridge_dellink
Date: Sun, 12 Apr 2015 23:17:09 -0700
Message-ID: <1428905838-14920-16-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36610 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbbDMGQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:48 -0400
Received: by pabsx10 with SMTP id sx10so91884900pab.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:48 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index b2d0477..b04fb5f 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4283,7 +4283,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_del			= rocker_port_fdb_del,
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= swdev_port_bridge_setlink,
-	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
+	.ndo_bridge_dellink		= swdev_port_bridge_dellink,
 	.ndo_get_phys_port_name		= rocker_port_get_phys_port_name,
 };
 
-- 
1.7.10.4
