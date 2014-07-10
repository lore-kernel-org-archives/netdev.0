From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 11/11] net: bcmgenet: hook ethtool set/get_wol operations
Date: Thu, 10 Jul 2014 15:46:24 -0700
Message-ID: <1405032384-24006-12-git-send-email-f.fainelli@gmail.com>
References: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:34979 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaGJWqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 18:46:39 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so3637420igb.11
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 15:46:38 -0700 (PDT)
In-Reply-To: <1405032384-24006-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that Wake-on-LAN support mode is fully integrated into the driver,
allow an user to query and configure Wake-on-LAN in the driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index e80afa3cc321..24fa9d88442f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -730,6 +730,8 @@ static struct ethtool_ops bcmgenet_ethtool_ops = {
 	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= bcmgenet_get_msglevel,
 	.set_msglevel		= bcmgenet_set_msglevel,
+	.get_wol		= bcmgenet_get_wol,
+	.set_wol		= bcmgenet_set_wol,
 };
 
 /* Power down the unimac, based on mode. */
-- 
1.9.1
