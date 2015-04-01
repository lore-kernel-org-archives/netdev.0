From: sfeldma@gmail.com
Subject: [PATCH net-next v2 22/26] team: cut over to new swdev_port_bridge_getlink
Date: Wed,  1 Apr 2015 03:07:58 -0700
Message-ID: <1427882882-2533-23-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34693 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbbDAKGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:52 -0400
Received: by pactp5 with SMTP id tp5so47808011pac.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:52 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/team/team.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 261e9c5..6500fd7 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1978,6 +1978,7 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
 	.ndo_bridge_setlink	= swdev_port_bridge_setlink,
+	.ndo_bridge_getlink	= swdev_port_bridge_getlink,
 	.ndo_bridge_dellink	= swdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
-- 
1.7.10.4
