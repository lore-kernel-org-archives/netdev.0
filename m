From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 0/2] net: phy: Fix module autoload for OF platform drivers
Date: Fri, 18 Sep 2015 18:15:53 +0200
Message-ID: <20150918161553.GA25782@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

These patches add the missing MODULE_DEVICE_TABLE() for OF to export
the information so modules have the correct aliases built-in and
autoloading works correctly.

A longer explanation by Javier Canillas can be found here:
https://lkml.org/lkml/2015/7/30/519

Sorry if these two patches should've been part of the ethernet series:
https://lkml.org/lkml/2015/9/18/567

Thanks,
Luis

Luis de Bethencourt (2):
  net: phy: mdio-bcm-unimac: Fix module autoload for OF platform driver
  net: phy: mdio-gpio: Fix module autoload for OF platform driver

 drivers/net/phy/mdio-bcm-unimac.c | 1 +
 drivers/net/phy/mdio-gpio.c       | 1 +
 2 files changed, 2 insertions(+)

-- 
2.4.6
