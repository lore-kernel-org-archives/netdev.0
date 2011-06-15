From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] phylib: Allow BCM63XX PHY to be selected only on BCM63XX.
Date: Wed, 15 Jun 2011 09:07:58 +0100
Message-ID: <20110615080758.GA3226@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	Florian Fainelli <ffainelli@freebox.fr>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h5.dl5rb.org.uk ([81.2.74.5]:55170 "EHLO duck.linux-mips.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751319Ab1FOIIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 04:08:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This PHY is available integrated into BCM63xx series SOCs only.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/net/phy/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 392a6c4..a702443 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -58,6 +58,7 @@ config BROADCOM_PHY
 
 config BCM63XX_PHY
 	tristate "Drivers for Broadcom 63xx SOCs internal PHY"
+	depends on BCM63XX
 	---help---
 	  Currently supports the 6348 and 6358 PHYs.
 
