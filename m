From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 0/3] pch_gbe: few clean ups to the driver
Date: Fri, 28 Jun 2013 14:02:51 +0300
Message-ID: <1372417374-28128-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Darren Hart <dvhart@linux.intel.com>,
	Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:64651 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753462Ab3F1L3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 07:29:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are three clean ups to the driver.

Since v2:
- the additional arguments on subsequent lines are realigned to the open
  parenthesis

Since v1:
- remove hunk that is not belong the topic
- address Joe's comments

Andy Shevchenko (3):
  pch_gbe: remove inline keyword for exported functions
  pch_gbe: convert pr_* to netdev_*
  pch_gbe: use managed functions pcim_* and devm_*

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |   2 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |  70 +++--
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 327 +++++++++++----------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |  63 ++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    |  26 +-
 6 files changed, 278 insertions(+), 212 deletions(-)

-- 
1.8.3.1
