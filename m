From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 08/26] phy: export phy_start_machine() for phylink
Date: Mon, 07 Dec 2015 17:37:52 +0000
Message-ID: <E1a5zjU-00075C-Dn@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60273 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbbLGRhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:37:55 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phylink will need phy_start_machine exported, so lets export it as a
GPL symbol.  Documentation/networking/phy.txt indicates that this
should be a PHY API function.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 150497246922..ec9953202f58 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -523,6 +523,7 @@ void phy_start_machine(struct phy_device *phydev)
 {
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, HZ);
 }
+EXPORT_SYMBOL_GPL(phy_start_machine);
 
 /**
  * phy_stop_machine - stop the PHY state machine tracking
-- 
2.1.0
