From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-03-01
Date: Tue, 01 Mar 2011 01:16:09 +0000
Message-ID: <1298942169.3069.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:11590 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab1CABQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 20:16:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 5b2c4dd2ec12cf0e53b2bd2926f0fe2d1fbb4eda:
  Jiri Pirko (1):
        net: convert bonding to use rx_handler

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

Ben Hutchings (6):
      sfc: Read MC firmware version when requested through ethtool
      sfc: Do not read STAT1.FAULT in efx_mdio_check_mmd()
      sfc: Update copyright dates
      sfc: Expose TX push and TSO counters through ethtool statistics
      sfc: Remove configurable FIFO thresholds for pause frame generation
      sfc: Bump version to 3.1

Steve Hodgson (2):
      sfc: Reduce size of efx_rx_buffer by unionising skb and page
      sfc: Reduce size of efx_rx_buffer further by removing data member

 drivers/net/sfc/efx.c           |    2 +-
 drivers/net/sfc/efx.h           |    2 +-
 drivers/net/sfc/ethtool.c       |   27 ++++++-
 drivers/net/sfc/falcon.c        |   22 ++----
 drivers/net/sfc/falcon_boards.c |    2 +-
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/sfc/io.h            |    2 +-
 drivers/net/sfc/mcdi.c          |   23 ++----
 drivers/net/sfc/mcdi.h          |    4 +-
 drivers/net/sfc/mcdi_mac.c      |    2 +-
 drivers/net/sfc/mcdi_pcol.h     |    2 +-
 drivers/net/sfc/mcdi_phy.c      |    2 +-
 drivers/net/sfc/mdio_10g.c      |   34 ++--------
 drivers/net/sfc/mdio_10g.h      |    5 +-
 drivers/net/sfc/mtd.c           |    2 +-
 drivers/net/sfc/net_driver.h    |   14 ++--
 drivers/net/sfc/nic.c           |   22 +------
 drivers/net/sfc/nic.h           |    9 +--
 drivers/net/sfc/phy.h           |    2 +-
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/regs.h          |    2 +-
 drivers/net/sfc/rx.c            |  144 +++++++++++++++++++-------------------
 drivers/net/sfc/selftest.c      |    2 +-
 drivers/net/sfc/selftest.h      |    2 +-
 drivers/net/sfc/siena.c         |   24 +------
 drivers/net/sfc/spi.h           |    2 +-
 drivers/net/sfc/tenxpress.c     |    4 +-
 drivers/net/sfc/tx.c            |    2 +-
 drivers/net/sfc/txc43128_phy.c  |    4 +-
 drivers/net/sfc/workarounds.h   |    2 +-
 30 files changed, 150 insertions(+), 220 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

