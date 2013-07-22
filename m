From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH V2 net-next 0/2] pch_gbe: Add MinnowBoard support
Date: Mon, 22 Jul 2013 14:41:55 -0700
Message-ID: <cover.1374525261.git.dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Darren Hart <dvhart@linux.intel.com>,
	Joe Perches <joe@perches.com>
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57428 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932873Ab3GVVmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 17:42:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the MinnowBoard in the pch_gbe driver. This was
originally sent to LKML as part of the MinnowBoard support series. That
is now partially merged and this version of the patch has been isolated
from those changes and is now completely self-contained.

Thanks to everyone on Cc for their time in reviewing, the patch series
is better for it.

Since the previous version:
  Whitespace cleanup
  Remove trailing period in messages
  Comment formatting (added a colon)
  Use devm_gpio_request_one
  Fix missing adapter->pdata NULL check in PHY
  Use netdev style comment blocks
  Use kernel_ulong_t for driver_data cast
  Use unsigned for gpio and unsigned long for flags

The following changes since commit 0887a576a17965732270b2f8d37821fc02ef2feb:

  net/velocity: add poll controller function for velocity nic (2013-07-19 17:34:41 -0700)

are available in the git repository at:

  git://git.infradead.org/users/dvhart/linux-2.6.git minnow/net-next
  ssh://git.infradead.org/srv/git/users/dvhart/linux-2.6.git minnow/net-next

and browsable here:

  http://git.infradead.org/users/dvhart/linux-2.6.git/shortlog/refs/heads/minnow/net-next

Darren Hart (2):
  pch_gbe: Use PCH_GBE_PHY_REGS_LEN instead of 32
  pch_gbe: Add MinnowBoard support

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 14 ++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 52 +++++++++++-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 96 ++++++++++++++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
 4 files changed, 163 insertions(+), 1 deletion(-)

-- 
1.8.3.1
