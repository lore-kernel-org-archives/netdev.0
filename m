From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/2] net: sun4i-emac: Staticize local symbols
Date: Tue,  4 Jun 2013 16:01:20 +0530
Message-ID: <1370341880-26501-2-git-send-email-sachin.kamat@linaro.org>
References: <1370341880-26501-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Stefan Roese <sr@denx.de>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:41374 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab3FDKpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 06:45:42 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so57624pdj.0
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 03:45:42 -0700 (PDT)
In-Reply-To: <1370341880-26501-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some symbols referenced only in this file are made static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Stefan Roese <sr@denx.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 0049853..7d6a5cd 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -258,7 +258,7 @@ static const struct ethtool_ops emac_ethtool_ops = {
 	.get_link	= ethtool_op_get_link,
 };
 
-unsigned int emac_setup(struct net_device *ndev)
+static unsigned int emac_setup(struct net_device *ndev)
 {
 	struct emac_board_info *db = netdev_priv(ndev);
 	unsigned int reg_val;
@@ -310,7 +310,7 @@ unsigned int emac_setup(struct net_device *ndev)
 	return 0;
 }
 
-unsigned int emac_powerup(struct net_device *ndev)
+static unsigned int emac_powerup(struct net_device *ndev)
 {
 	struct emac_board_info *db = netdev_priv(ndev);
 	unsigned int reg_val;
-- 
1.7.9.5
