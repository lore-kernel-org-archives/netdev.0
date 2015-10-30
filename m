From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 0/2] net: encx24j600: Fix SPI driver module autoload
Date: Fri, 30 Oct 2015 13:49:16 +0100
Message-ID: <1446209358-26094-1-git-send-email-javier@osg.samsung.com>
Cc: netdev@vger.kernel.org, Jon Ringle <jringle@gridpoint.com>,
	davem@davemloft.net,
	Javier Martinez Canillas <javier@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Recently I've been trying to fix module autoloading for all SPI drivers and
found that the encx24j600 driver does not fill module alias information due
missing a MODULE_DEVICE_TABLE() so module autload won't work and the driver
Kconfig symbol is tristate which means the driver can be built as a module.

But also the SPI id table is not correctly defined so this series fixes both
issues.

The patches have been applied on top of the next-next tree master branch:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master

Best regards,
Javier


Javier Martinez Canillas (2):
  net: encx24j600: Fix SPI id table definition
  net: encx24j600: Export missing SPI module alias information

 drivers/net/ethernet/microchip/encx24j600.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

-- 
2.4.3
