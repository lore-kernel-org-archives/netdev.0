From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/2] sfc: Falcon board/PHY support
Date: Wed, 22 Sep 2010 20:58:21 +0100
Message-ID: <1285185501.2279.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:23959 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353Ab0IVT6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 15:58:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches update the board and PHY code to support precisely the
boards that are actually in use.

Ben.

Ben Hutchings (2):
  sfc: Remove support for SFN4111T, SFT9001 and Falcon GMAC
  sfc: Add support for SFE4003 board and TXC43128 PHY

 drivers/net/sfc/Makefile        |    5 +-
 drivers/net/sfc/falcon.c        |  120 ++-------
 drivers/net/sfc/falcon_boards.c |  203 ++++++---------
 drivers/net/sfc/falcon_gmac.c   |  230 ----------------
 drivers/net/sfc/mac.h           |    1 -
 drivers/net/sfc/mdio_10g.c      |   30 +--
 drivers/net/sfc/net_driver.h    |    2 -
 drivers/net/sfc/phy.h           |   18 +-
 drivers/net/sfc/tenxpress.c     |  424 ++---------------------------
 drivers/net/sfc/txc43128_phy.c  |  560 +++++++++++++++++++++++++++++++++++++++
 drivers/net/sfc/workarounds.h   |    9 +-
 11 files changed, 710 insertions(+), 892 deletions(-)
 delete mode 100644 drivers/net/sfc/falcon_gmac.c
 create mode 100644 drivers/net/sfc/txc43128_phy.c

-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

