From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/3] nfp: implement ethtool .get_link() callback
Date: Wed, 29 Jun 2016 21:55:55 +0100
Message-ID: <1467233755-14334-4-git-send-email-jakub.kicinski@netronome.com>
References: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38170 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbcF2VEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 17:04:30 -0400
Received: by mail-wm0-f53.google.com with SMTP id r201so91002367wme.1
        for <netdev@vger.kernel.org>; Wed, 29 Jun 2016 14:04:29 -0700 (PDT)
In-Reply-To: <1467233755-14334-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Point the ethtool .get_link() callback to the standard
ethtool_op_get_link() implementation.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index ccfef1f17627..7d7933d00b8f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -605,6 +605,7 @@ static int nfp_net_set_coalesce(struct net_device *netdev,
 
 static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.get_drvinfo		= nfp_net_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
 	.get_ringparam		= nfp_net_get_ringparam,
 	.set_ringparam		= nfp_net_set_ringparam,
 	.get_strings		= nfp_net_get_strings,
-- 
1.9.1
