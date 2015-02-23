From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT PATCH 2/2] net: dsa: mv88e6352: Add support for EEE
Date: Mon, 23 Feb 2015 08:26:10 -0800
Message-ID: <1424708770-3135-2-git-send-email-linux@roeck-us.net>
References: <1424708770-3135-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39144 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbbBWQ0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 11:26:17 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPvpo-001wGx-PD
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 16:26:17 +0000
In-Reply-To: <1424708770-3135-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable EEE support for MV88E6352.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
Applies to net-next.

Support for other chips using the mv88e6xxx code can be added
with similar patches.

 drivers/net/dsa/mv88e6352.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 1ebd8f9..7bc5998 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -717,6 +717,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.get_strings		= mv88e6352_get_strings,
 	.get_ethtool_stats	= mv88e6352_get_ethtool_stats,
 	.get_sset_count		= mv88e6352_get_sset_count,
+	.set_eee		= mv88e6xxx_set_eee,
+	.get_eee		= mv88e6xxx_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6352_get_temp,
 	.get_temp_limit		= mv88e6352_get_temp_limit,
-- 
2.1.0
