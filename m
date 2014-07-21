From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 11/11] net: bcmgenet: hook ethtool set/get_wol operations
Date: Mon, 21 Jul 2014 15:29:29 -0700
Message-ID: <1405981769-24618-12-git-send-email-f.fainelli@gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:56331 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107AbaGUW37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 18:29:59 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so10707812pac.32
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 15:29:59 -0700 (PDT)
In-Reply-To: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that Wake-on-LAN support mode is fully integrated into the driver,
allow an user to query and configure Wake-on-LAN in the driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 62ef49c85980..0173a6d355aa 100644
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
