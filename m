From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-02-26
Date: Tue, 26 Feb 2013 19:09:23 +0000
Message-ID: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	scrum-linux <scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35913 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757187Ab3BZTJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:09:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit eb970ff07c15f13eb474f643fd165ebe3e4e24b2:

  usbnet: smsc95xx: rename FEATURE_AUTOSUSPEND (2013-02-25 15:49:52 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.9

Some fixes that should go into 3.9:

1. Fix packet corruption when using non-coherent RX DMA buffers.
2. Fix occasional watchdog misfiring when changing MTU or ring size.

These are longstanding bugs and should be fixed in stable as well, but
I'd like to review other recent fixes first and send a separate request
for stable inclusion.

Ben.

Ben Hutchings (3):
      sfc: Properly sync RX DMA buffer when it is not the last in the page
      sfc: Fix efx_rx_buf_offset() in the presence of swiotlb
      sfc: Detach net device when stopping queues for reconfiguration

 drivers/net/ethernet/sfc/efx.c        |   16 ++++++++++++----
 drivers/net/ethernet/sfc/net_driver.h |    4 +++-
 drivers/net/ethernet/sfc/rx.c         |   25 +++++++++++++++----------
 3 files changed, 30 insertions(+), 15 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
