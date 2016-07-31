From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] mwifiex: remove superfluous condition
Date: Sun, 31 Jul 2016 12:39:15 +0200
Message-ID: <1469961555-2123-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:60033 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbcGaKje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 06:39:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for_each_property_of_node is only executed if the
property prop is not NULL.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
index 7897037..128add8 100644
--- a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
@@ -1482,7 +1482,7 @@ int mwifiex_dnld_dt_cfgdata(struct mwifiex_private *priv,
 			continue;
 
 		/* property header is 6 bytes, data must fit in cmd buffer */
-		if (prop && prop->value && prop->length > 6 &&
+		if (prop->value && prop->length > 6 &&
 		    prop->length <= MWIFIEX_SIZE_OF_CMD_BUFFER - S_DS_GEN) {
 			ret = mwifiex_send_cmd(priv, HostCmd_CMD_CFG_DATA,
 					       HostCmd_ACT_GEN_SET, 0,
-- 
2.8.1
