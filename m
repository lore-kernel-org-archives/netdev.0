From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net:master 6/7] mdio-gpio.c:(.text+0x58): multiple definition of
 `of_mdiobus_register'
Date: Wed, 10 Oct 2012 07:28:18 +0800
Message-ID: <20121009232818.GB9331@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33696 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686Ab2JIX2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 19:28:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

FYI, kernel build failed on

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   5175a5e76bbdf20a614fb47ce7a38f0f39e70226
commit: 4085a7f0a09c73ef3e9de113c9f04d78c79be645 [6/7] netdev/phy: Prototype of_mdio_find_bus()
config: i386-allyesconfig

All error/warnings:

drivers/net/phy/mdio-gpio.o: In function `of_mdiobus_register':
mdio-gpio.c:(.text+0x58): multiple definition of `of_mdiobus_register'
drivers/net/phy/libphy.o:(.text+0x23d7): first defined here
drivers/net/phy/mdio-gpio.o: In function `of_phy_find_device':
mdio-gpio.c:(.text+0x67): multiple definition of `of_phy_find_device'
drivers/net/phy/libphy.o:(.text+0x23e6): first defined here
drivers/net/phy/mdio-gpio.o: In function `of_phy_connect':
mdio-gpio.c:(.text+0x73): multiple definition of `of_phy_connect'
drivers/net/phy/libphy.o:(.text+0x23f2): first defined here
drivers/net/phy/mdio-gpio.o: In function `of_phy_connect_fixed_link':
mdio-gpio.c:(.text+0x7f): multiple definition of `of_phy_connect_fixed_link'
drivers/net/phy/libphy.o:(.text+0x23fe): first defined here
drivers/net/phy/mdio-gpio.o: In function `of_mdio_find_bus':
mdio-gpio.c:(.text+0x8b): multiple definition of `of_mdio_find_bus'
drivers/net/phy/libphy.o:(.text+0x240a): first defined here

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
