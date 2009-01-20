From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] phy: Add suspend/resume support to SMSC PHYs
Date: Tue, 20 Jan 2009 13:43:58 +0000
Message-ID: <1232459038-13156-1-git-send-email-steve.glendinning@smsc.com>
Cc: David Miller <davem@davemloft.net>,
	Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sandgatehouse.force9.co.uk ([84.92.144.20]:35108 "EHLO
	kensington.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754995AbZATNnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 08:43:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All supported SMSC PHYs implement the standard "power down" bit 11 of
BMCR, so this patch adds support using the generic genphy_{suspend,resume}
functions.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/phy/smsc.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index c05d38d..185dcd9 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -81,6 +81,9 @@ static struct phy_driver lan83c185_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+        .suspend	= genphy_suspend,
+        .resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
@@ -102,6 +105,9 @@ static struct phy_driver lan8187_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+        .suspend	= genphy_suspend,
+        .resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
@@ -123,6 +129,9 @@ static struct phy_driver lan8700_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+        .suspend	= genphy_suspend,
+        .resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
@@ -144,6 +153,9 @@ static struct phy_driver lan911x_int_driver = {
 	.ack_interrupt	= smsc_phy_ack_interrupt,
 	.config_intr	= smsc_phy_config_intr,
 
+        .suspend	= genphy_suspend,
+        .resume		= genphy_resume,
+
 	.driver		= { .owner = THIS_MODULE, }
 };
 
-- 
1.6.0.6

