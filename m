From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 3/3] phy: Add suspend/resume functions to Micrel PHY
Date: Tue, 18 May 2010 07:39:26 +0200
Message-ID: <1274161166-18521-4-git-send-email-jonas@southpole.se>
References: <1274161166-18521-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:35395 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756606Ab0ERF6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 01:58:32 -0400
In-Reply-To: <1274161166-18521-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the generic suspend and resume functions, as the genphy driver does.
---
 drivers/net/phy/micrel.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index e67691d..c38a0bb 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -39,6 +39,8 @@ static struct phy_driver ks8001_driver = {
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -51,6 +53,8 @@ static struct phy_driver vsc8201_driver = {
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE,},
 };
 
@@ -63,6 +67,8 @@ static struct phy_driver ksz9021_driver = {
 	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
+	.suspend	= genphy_suspend,
+	.resume		= genphy_resume,
 	.driver		= { .owner = THIS_MODULE, },
 };
 
-- 
1.7.0.4

