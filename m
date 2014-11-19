From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 01/10] net: phy: add static data field to struct phy_driver
Date: Wed, 19 Nov 2014 12:59:14 +0100
Message-ID: <1416398363-32306-2-git-send-email-johan@kernel.org>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36115 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbaKSL7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 06:59:48 -0500
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add static driver-data field to struct phy_driver, which can be used to
store structured device-type information.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 include/linux/phy.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 07794e720139..22af8f8f5802 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -433,6 +433,7 @@ struct phy_device {
  *   by this PHY
  * flags: A bitfield defining certain other features this PHY
  *   supports (like interrupts)
+ * driver_data: static driver data
  *
  * The drivers must implement config_aneg and read_status.  All
  * other functions are optional. Note that none of these
@@ -448,6 +449,7 @@ struct phy_driver {
 	unsigned int phy_id_mask;
 	u32 features;
 	u32 flags;
+	const void *driver_data;
 
 	/*
 	 * Called to issue a PHY software reset
-- 
2.0.4
