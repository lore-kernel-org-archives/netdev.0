From: sfeldma@gmail.com
Subject: [PATCH net-next v3 17/26] team: cut over to new swdev_port_bridge_dellink
Date: Thu,  2 Apr 2015 01:10:03 -0700
Message-ID: <1427962212-18411-18-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:36765 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbbDBIJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:41 -0400
Received: by pdea3 with SMTP id a3so30773190pde.3
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:40 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/team/team.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6a3debc..261e9c5 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1978,7 +1978,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink	= swdev_port_bridge_setlink,
-	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
+	.ndo_bridge_dellink	= swdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
 
-- 
1.7.10.4
