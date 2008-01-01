From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 18/26] atl1: make function static
Date: Mon, 31 Dec 2007 20:22:45 -0600
Message-ID: <1199154173-4058-19-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([207.115.11.56]:64425 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753027AbYAAC2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:19 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make atl1_reset() a static function.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 6432956..7697e80 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2351,12 +2351,13 @@ static void atl1_phy_config(unsigned long data)
 	clear_bit(0, &adapter->cfg_phy);
 }
 
-int atl1_reset(struct atl1_adapter *adapter)
+static int atl1_reset(struct atl1_adapter *adapter)
 {
-	int ret;
-	ret = atl1_reset_hw(&adapter->hw);
-	if (ret)
-		return ret;
+	int retval;
+
+	retval = atl1_reset_hw(&adapter->hw);
+	if (retval)
+		return retval;
 	return atl1_init_hw(&adapter->hw);
 }
 
-- 
1.5.3.3

