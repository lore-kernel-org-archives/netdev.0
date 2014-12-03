From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/2] rocker: fix eth_type type in struct rocker_ctrl
Date: Wed,  3 Dec 2014 14:14:54 +0100
Message-ID: <1417612494-3788-2-git-send-email-jiri@resnulli.us>
References: <1417612494-3788-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:46689 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbaLCNO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:14:59 -0500
Received: by mail-wg0-f53.google.com with SMTP id l18so19508875wgh.26
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 05:14:57 -0800 (PST)
In-Reply-To: <1417612494-3788-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
v1->v2:
-fixed typo in subject pointed out by Sergei
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
