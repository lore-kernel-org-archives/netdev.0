From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 0/3] pch_gbe: few clean ups to the driver
Date: Thu, 27 Jun 2013 12:23:11 +0300
Message-ID: <1372324994-27793-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Darren Hart <dvhart@linux.intel.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35839 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab3F0JXW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 05:23:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are three clean ups to the driver.

Since v1:
 - remove hunk that is not belong the topic
 - address Joe's comments

Andy Shevchenko (3):
  pch_gbe: remove inline keyword for exported functions
  pch_gbe: convert pr_* to netdev_*
  pch_gbe: use managed functions pcim_* and devm_*

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |   2 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |  70 ++++--
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 279 +++++++++++----------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |  61 +++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    |  26 +-
 6 files changed, 251 insertions(+), 189 deletions(-)

-- 
1.8.3.1
