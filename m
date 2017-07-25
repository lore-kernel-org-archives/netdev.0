From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 06/13] net: phy: export phy_start_machine() for phylink
Date: Tue, 25 Jul 2017 15:03:03 +0100
Message-ID: <E1da0QR-0007LZ-7T@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50878 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752005AbdGYODK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:03:10 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phylink will need phy_start_machine exported, so lets export it as a
GPL symbol.  Documentation/networking/phy.txt indicates that this
should be a PHY API function.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5fd411ed3b85..ba92c4ca21f3 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -557,6 +557,7 @@ void phy_start_machine(struct phy_device *phydev)
 {
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, HZ);
 }
+EXPORT_SYMBOL_GPL(phy_start_machine);
 
 /**
  * phy_trigger_machine - trigger the state machine to run
-- 
2.7.4
