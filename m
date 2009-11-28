From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 29/32] sfc: Move shared NIC code and definitions from
	falcon.{c,h} to nic.{c,h}
Date: Sat, 28 Nov 2009 03:56:22 +0000
Message-ID: <1259380582.2811.70.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42897 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbZK1D4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:56:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
No diff for this; it's too large for netdev.

Ben.

 drivers/net/sfc/Makefile        |    2 +-
 drivers/net/sfc/efx.c           |    2 +-
 drivers/net/sfc/ethtool.c       |    2 +-
 drivers/net/sfc/falcon.c        | 1538 +--------------------------------------
 drivers/net/sfc/falcon.h        |  238 ------
 drivers/net/sfc/falcon_boards.c |    2 +-
 drivers/net/sfc/falcon_gmac.c   |    2 +-
 drivers/net/sfc/falcon_xmac.c   |    2 +-
 drivers/net/sfc/mdio_10g.c      |    2 +-
 drivers/net/sfc/mtd.c           |    2 +-
 drivers/net/sfc/nic.c           | 1548 +++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/nic.h           |  238 ++++++
 drivers/net/sfc/qt202x_phy.c    |    2 +-
 drivers/net/sfc/rx.c            |    2 +-
 drivers/net/sfc/selftest.c      |    2 +-
 drivers/net/sfc/tenxpress.c     |    2 +-
 drivers/net/sfc/tx.c            |    2 +-
 17 files changed, 1800 insertions(+), 1788 deletions(-)
 delete mode 100644 drivers/net/sfc/falcon.h
 create mode 100644 drivers/net/sfc/nic.c
 create mode 100644 drivers/net/sfc/nic.h

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

