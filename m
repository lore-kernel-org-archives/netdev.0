From: roopa@cumulusnetworks.com
Subject: [PATCH net-next 3/3] team: add support for ndo_switch_port_stp_update when team dev is a bridge port
Date: Thu,  5 Mar 2015 20:04:18 -0800
Message-ID: <1425614658-43701-4-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34260 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbCFEE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 23:04:27 -0500
Received: by paceu11 with SMTP id eu11so34253514pac.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 20:04:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for stp state offload netdev op to support the case
where team dev is a bridge port and team slaves are switch ports.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/team/team.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a7d163b..8d96f89 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1981,6 +1981,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
 	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
+	.ndo_switch_port_stp_update = ndo_dflt_netdev_switch_port_stp_update,
 };
 
 /***********************
-- 
1.7.10.4
