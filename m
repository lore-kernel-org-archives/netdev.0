From: Luis de Bethencourt <luis@debethencourt.com>
Subject: [PATCH 0/6] net: Fix module autoload for OF platform drivers
Date: Fri, 18 Sep 2015 17:53:32 +0200
Message-ID: <20150918155332.GA24705@goodgumbo.baconseed.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfram Sang <wsa@the-dreams.de>,
	Joe Perches <joe@perches.com>,
	Tobias Klauser <tklauser@distanz.ch>
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

Thanks,
Luis

Luis de Bethencourt (6):
  net: arc: Fix module autoload for OF platform driver
  net: systemport: Fix module autoload for OF platform driver
  net: bcmgenet: Fix module autoload for OF platform driver
  net: freescale: Fix module autoload for OF platform driver
  net: ks8851: Fix module autoload for OF platform driver
  net: moxa: Fix module autoload for OF platform driver

 drivers/net/ethernet/arc/emac_arc.c            | 1 +
 drivers/net/ethernet/broadcom/bcmsysport.c     | 1 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 1 +
 drivers/net/ethernet/freescale/gianfar_ptp.c   | 1 +
 drivers/net/ethernet/micrel/ks8851.c           | 1 +
 drivers/net/ethernet/moxa/moxart_ether.c       | 1 +
 6 files changed, 6 insertions(+)

-- 
2.4.6
