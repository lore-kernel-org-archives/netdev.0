From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [net-next v2 3/3] net: bcmgenet: remove unused bh_lock member
Date: Mon, 24 Feb 2014 16:56:13 -0800
Message-ID: <1393289773-9473-4-git-send-email-f.fainelli@gmail.com>
References: <1393289773-9473-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12410 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbaBYA4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:56:24 -0500
In-Reply-To: <1393289773-9473-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bh_lock spinlock is unused, remove it from the private driver structure.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 8e48db8..a6758ad 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -524,7 +524,6 @@ struct bcmgenet_priv {
 	enum bcmgenet_version version;
 	struct net_device *dev;
 	spinlock_t lock;
-	spinlock_t bh_lock;
 	u32 int0_mask;
 	u32 int1_mask;
 
-- 
1.8.3.2
