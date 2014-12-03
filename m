From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] rocker: fix eth_type tybe in struct rocker_ctrl
Date: Wed,  3 Dec 2014 11:32:33 +0100
Message-ID: <1417602753-3084-2-git-send-email-jiri@resnulli.us>
References: <1417602753-3084-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:48832 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbaLCKci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 05:32:38 -0500
Received: by mail-wg0-f46.google.com with SMTP id a1so11144573wgh.5
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 02:32:36 -0800 (PST)
In-Reply-To: <1417602753-3084-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 4b060fb..5536435 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -2753,7 +2753,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 static struct rocker_ctrl {
 	const u8 *eth_dst;
 	const u8 *eth_dst_mask;
-	u16 eth_type;
+	__be16 eth_type;
 	bool acl;
 	bool bridge;
 	bool term;
-- 
1.9.3
