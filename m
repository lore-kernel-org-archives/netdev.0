From: Simon Baatz <gmbnomis@gmail.com>
Subject: [PATCH 1/2] net: mvmdio: define module alias for platform device
Date: Sun, 24 Mar 2013 21:33:59 +0100
Message-ID: <1364157240-28883-2-git-send-email-gmbnomis@gmail.com>
References: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
Cc: jason@lakedaemon.net, andrew@lunn.ch, davem@davemloft.net,
	Simon Baatz <gmbnomis@gmail.com>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, florian@openwrt.org,
	thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:10680 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463Ab3CXUer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 16:34:47 -0400
In-Reply-To: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvmdio driver can be instantiated using device tree or as a classic
platform device.  In order to load the driver automatically by udev in
the latter case, the driver needs to define a module alias for the
platform device.

Signed-off-by: Simon Baatz <gmbnomis@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 3472574..7b5158f 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -295,3 +295,4 @@ module_platform_driver(orion_mdio_driver);
 MODULE_DESCRIPTION("Marvell MDIO interface driver");
 MODULE_AUTHOR("Thomas Petazzoni <thomas.petazzoni@free-electrons.com>");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("platform:orion-mdio");
-- 
1.7.9.5
