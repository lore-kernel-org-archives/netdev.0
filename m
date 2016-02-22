From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [PATCH 2/3] gianfar_ptp: fix endianness in get_of_u32()
Date: Mon, 22 Feb 2016 14:49:32 +0800
Message-ID: <1456123773-1016-3-git-send-email-yangbo.lu@nxp.com>
References: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0059.outbound.protection.outlook.com ([65.55.169.59]:56015
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753656AbcBVHcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2016 02:32:18 -0500
In-Reply-To: <1456123773-1016-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index b40fba9..a86145c 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -431,7 +431,7 @@ static int get_of_u32(struct device_node *node, char *str, u32 *val)
 
 	if (!prop || plen != sizeof(*prop))
 		return -1;
-	*val = *prop;
+	*val = be32_to_cpu(*prop);
 	return 0;
 }
 
-- 
2.1.0.27.g96db324
