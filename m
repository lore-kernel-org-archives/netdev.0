From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next 2011-07-14
Date: Thu, 14 Jul 2011 02:14:50 +0100
Message-ID: <1310606090.2756.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:11021 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab1GNBOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 21:14:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit e77aeb71f04ed236fffe5f347e208c8b0e92d48a:

  net: de4x5: Omit check for multicast bit in netdev_for_each_mc_addr (2011-07-01 01:51:03 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git master

A variety of fixes and cosmetic changes.

Ben.

Ben Hutchings (6):
      sfc: Fix loop condition for efx_filter_search() when !for_insert
      sfc: Allow resets to be upgraded; use atomic ops for safety
      sfc: Fix mapping of reset reasons and flags to methods
      sfc: Fix assertions in efx_filter_rfs()
      sfc: Remove 'Solarstorm' from Kconfig descriptions
      sfc: Remove 'Communications' after 'Solarflare' in references to hardware

Steve Hodgson (1):
      sfc: Fix Siena mac statistics on big endian platforms

 drivers/net/sfc/Kconfig      |    7 ++---
 drivers/net/sfc/efx.c        |   60 ++++++++++++++++--------------------------
 drivers/net/sfc/enum.h       |    3 +-
 drivers/net/sfc/ethtool.c    |   27 +++---------------
 drivers/net/sfc/falcon.c     |   51 +++++++++++++++++++++++++++++++++--
 drivers/net/sfc/filter.c     |   45 ++++++++++++++++++-------------
 drivers/net/sfc/net_driver.h |   11 ++++---
 drivers/net/sfc/siena.c      |   47 +++++++++++++++++++++++++++-----
 8 files changed, 152 insertions(+), 99 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

