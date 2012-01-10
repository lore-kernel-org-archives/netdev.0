From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 20/21] mdio-gpio: use an unique MDIO bus name.
Date: Tue, 10 Jan 2012 10:59:26 +0100
Message-ID: <1326189567-21663-21-git-send-email-florian@openwrt.org>
References: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Cc: Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@secretlab.ca>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Dirk Eibach <eibach@gdsys.de>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59929 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756136Ab2AJKBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 05:01:23 -0500
In-Reply-To: <1326189567-21663-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/phy/mdio-gpio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 89c5a3e..50e8e5e 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -116,7 +116,7 @@ static struct mii_bus * __devinit mdio_gpio_bus_init(struct device *dev,
 		if (!new_bus->irq[i])
 			new_bus->irq[i] = PHY_POLL;
 
-	snprintf(new_bus->id, MII_BUS_ID_SIZE, "%x", bus_id);
+	snprintf(new_bus->id, MII_BUS_ID_SIZE, "gpio-%x", bus_id);
 
 	if (gpio_request(bitbang->mdc, "mdc"))
 		goto out_free_bus;
-- 
1.7.5.4
