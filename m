From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 1/3] net/phy/davicom: add irq functions to DM9161E and DM9161A
Date: Sun, 11 Nov 2012 23:23:25 +0100
Message-ID: <1352672607-12793-2-git-send-email-manabian@gmail.com>
References: <1352672607-12793-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:36644 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab2KKWYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 17:24:00 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so4139356lag.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 14:23:59 -0800 (PST)
In-Reply-To: <1352672607-12793-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both these PHYs support interrupt generation on IC pin 32.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/phy/davicom.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/davicom.c b/drivers/net/phy/davicom.c
index 81c7bc0..a2ad421 100644
--- a/drivers/net/phy/davicom.c
+++ b/drivers/net/phy/davicom.c
@@ -153,6 +153,8 @@ static struct phy_driver dm91xx_driver[] = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x0181b8a0,
@@ -162,6 +164,8 @@ static struct phy_driver dm91xx_driver[] = {
 	.config_init	= dm9161_config_init,
 	.config_aneg	= dm9161_config_aneg,
 	.read_status	= genphy_read_status,
+	.ack_interrupt	= dm9161_ack_interrupt,
+	.config_intr	= dm9161_config_intr,
 	.driver		= { .owner = THIS_MODULE,},
 }, {
 	.phy_id		= 0x00181b80,
-- 
1.8.0
