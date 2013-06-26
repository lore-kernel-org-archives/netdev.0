From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 0/3] pch_gbe: few clean ups to the driver
Date: Wed, 26 Jun 2013 19:13:34 +0300
Message-ID: <1372263217-1938-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Darren Hart <dvhart@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:19170 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab3FZQNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 12:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are three clean ups to the driver.
Darren, can you incorporate this series to your Minnow board support?
Or if this goes first, consider rebase on top.

Andy Shevchenko (3):
  pch_gbe: remove inline keyword for exported functions
  pch_gbe: convert pr_* to netdev_*
  pch_gbe: use managed functions pcim_* and devm_*

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |   2 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |  48 ++--
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 279 +++++++++++----------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |  61 +++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    |  23 +-
 drivers/staging/media/lirc/lirc_igorplugusb.c      |   2 +-
 7 files changed, 237 insertions(+), 180 deletions(-)

-- 
1.8.3.1
