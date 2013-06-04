From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 4/8] drivers: net: phy: at803x: add support for AT8031
Date: Tue, 4 Jun 2013 11:40:07 +0530
Message-ID: <1370326212-17580-5-git-send-email-mugunthanvnm@ti.com>
References: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <benoit.cousson@linaro.org>,
	<paul@pwsan.com>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:60630 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759114Ab3FDGJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 02:09:49 -0400
In-Reply-To: <1370326212-17580-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for Atheros 8031 phy driver.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/phy/at803x.c |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index dda07ed..1f7091b 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -183,6 +183,21 @@ static struct phy_driver at803x_driver[] = {
 	.driver		= {
 		.owner = THIS_MODULE,
 	},
+}, {
+	/* ATHEROS 8031 */
+	.phy_id		= 0x004dd074,
+	.name		= "Atheros 8031 ethernet",
+	.phy_id_mask	= 0xffffffef,
+	.config_init	= at803x_config_init,
+	.set_wol	= at803x_set_wol,
+	.get_wol	= at803x_get_wol,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.driver		= {
+		.owner = THIS_MODULE,
+	},
 } };
 
 static int __init atheros_init(void)
-- 
1.7.9.5
