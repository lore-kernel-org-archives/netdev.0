From: Markus Pargmann <mpa@pengutronix.de>
Subject: [PATCH 2/2] net/ethernet: cpsw: DT read bool dual_emac
Date: Fri,  4 Oct 2013 14:44:40 +0200
Message-ID: <1380890680-30941-2-git-send-email-mpa@pengutronix.de>
References: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Cc: Florian Fainelli <florian@openwrt.org>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, Markus Pargmann <mpa@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34232 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312Ab3JDMpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 08:45:19 -0400
In-Reply-To: <1380890680-30941-1-git-send-email-mpa@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5df50a9..804846e 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1771,8 +1771,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->mac_control = prop;
 
-	if (!of_property_read_u32(node, "dual_emac", &prop))
-		data->dual_emac = prop;
+	if (of_property_read_bool(node, "dual_emac"))
+		data->dual_emac = 1;
 
 	/*
 	 * Populate all the child nodes here...
-- 
1.8.4.rc3
