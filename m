From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 00/10] sfc changes for 2.6.37
Date: Fri, 10 Sep 2010 17:40:17 +0100
Message-ID: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25356 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755575Ab0IJQkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:40:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One new feature - variable ring sizes - and a few bug fixes.

Ben.

Ben Hutchings (9):
  sfc: Use MCDI RX_BAD_FCS_PKTS count as MAC rx_bad count
  sfc: Accumulate RX_NODESC_DROP count in rx_dropped, not
    rx_over_errors
  sfc: Remove declarations of functions that no longer exist
  sfc: Fix failure paths in efx_probe_port()
  sfc: Allocate DMA and event rings using GFP_KERNEL
  sfc: Abstract channel and index lookup for RX queues
  sfc: Refactor channel and queue lookup and iteration
  sfc: Allocate each channel separately, along with its RX and TX
    queues
  sfc: Allow changing the DMA ring sizes dynamically via ethtool

Steve Hodgson (1):
  sfc: Make the dmaq size a run-time setting (rather than compile-time)

 drivers/net/sfc/efx.c        |  302 +++++++++++++++++++++++++++++++-----------
 drivers/net/sfc/efx.h        |   22 ++-
 drivers/net/sfc/ethtool.c    |   53 +++++++-
 drivers/net/sfc/falcon.c     |   14 +--
 drivers/net/sfc/net_driver.h |  103 ++++++++++-----
 drivers/net/sfc/nic.c        |  182 ++++++++++++++-----------
 drivers/net/sfc/rx.c         |   71 ++++++-----
 drivers/net/sfc/selftest.c   |    7 +-
 drivers/net/sfc/siena.c      |    2 +-
 drivers/net/sfc/tx.c         |   78 ++++++-----
 10 files changed, 543 insertions(+), 291 deletions(-)

-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

