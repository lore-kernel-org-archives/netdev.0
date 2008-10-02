From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [RFC,PATCHv2 0/3] phylib: give mdio buses a device tree presence
Date: Thu, 2 Oct 2008 03:41:21 +0200
Message-ID: <20081002014121.GA26575@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:42373 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbYJBBlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:41:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series hooks up mdio buses (struct mii_bus) into the device
tree, so that they show up in sysfs and can be found by walking the
device tree.

The main intended user for this is the DSA switch driver, but there
might be other uses as well.

Changes between v1 and v2:
- Add back accidentally deleted error handling from
  drivers/net/phy/mdio-bitbang.c (Andy Fleming).
- Deal with mdiobus_register() after mdiobus_unregister() properly.
- Make phy_read()/phy_write() inline functions and move them to
  include/linux/phy.h (Trent Piepho, Andy Fleming).
- Fix compilation of tc35815.
