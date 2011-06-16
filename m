From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Subject: [PATCH] net: icplus: remove unnecessary code
Date: Thu, 16 Jun 2011 12:04:30 -0500
Message-ID: <1308243870-30203-1-git-send-email-Gregory.Dietsche@cuw.edu>
Cc: kernel-janitors@vger.kernel.org, davem@davemloft.net,
	peppe.cavallaro@st.com, u.kleine-koenig@pengutronix.de,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta21.charter.net ([216.33.127.81]:41367 "EHLO
	mta21.charter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096Ab1FPREs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 13:04:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile tested.
remove unnecessary code that matches this coccinelle pattern
	if (...)
		return ret;
	return ret;

Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
---
 drivers/net/phy/icplus.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index 9a09e24..d4cbc29 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -109,11 +109,7 @@ static int ip1001_config_init(struct phy_device *phydev)
 	value = phy_read(phydev, 16);
 	value |= 0x3;
 
-	err = phy_write(phydev, 16, value);
-	if (err < 0)
-		return err;
-
-	return err;
+	return phy_write(phydev, 16, value);
 }
 
 static int ip175c_read_status(struct phy_device *phydev)
-- 
1.7.2.5

