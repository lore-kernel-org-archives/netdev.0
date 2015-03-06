From: roopa@cumulusnetworks.com
Subject: [PATCH net-next 2/3] bond: add support for ndo_switch_port_stp_update when bond is a bridge port
Date: Thu,  5 Mar 2015 20:04:17 -0800
Message-ID: <1425614658-43701-3-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:44567 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685AbbCFEE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 23:04:27 -0500
Received: by padet14 with SMTP id et14so24257346pad.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 20:04:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support for stp state offload netdev op to support the case
where bond is a bridge port and bond slaves are switch ports.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 675b082..bf60535 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4005,6 +4005,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_fix_features	= bond_fix_features,
 	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
 	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
+	.ndo_switch_port_stp_update = ndo_dflt_netdev_switch_port_stp_update,
 };
 
 static const struct device_type bond_type = {
-- 
1.7.10.4
