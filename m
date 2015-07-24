From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 0/6] net/macb: fix for AVR32 and clean up
Date: Fri, 24 Jul 2015 21:23:58 +0300
Message-ID: <1437762244-2678-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8422 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484AbbGXSYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jul 2015 14:24:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems no one had tested recently the driver on AVR32 platforms such as
ATNGW100. This series bring it back to work.

Andy Shevchenko (6):
  net/macb: improve big endian CPU support
  net/macb: check if macb_config present
  net/macb: use dev_*() when netdev is not yet registered
  net/macb: suppress compiler warnings
  net/macb: replace macb_count_tx_descriptors() by DIV_ROUND_UP()
  net/macb: convert to kernel doc

 drivers/net/ethernet/cadence/macb.c | 125 ++++++++++++++++++++++++------------
 drivers/net/ethernet/cadence/macb.h |  34 ++++------
 include/linux/platform_data/macb.h  |  14 +++-
 3 files changed, 108 insertions(+), 65 deletions(-)

-- 
2.4.6
