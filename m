From: Darren Hart <dvhart@linux.intel.com>
Subject: [PATCH V4 net-next 0/2] pch_gbe: Add MinnowBoard support
Date: Thu, 25 Jul 2013 01:46:49 -0700
Message-ID: <cover.1374741670.git.dvhart@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Darren Hart <dvhart@linux.intel.com>,
	Joe Perches <joe@perches.com>
To: Linux Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29104 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab3GYIqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 04:46:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy caught a couple more nits which I should have caught (and one I am
surprised that checkpatch did not catch). I have read over this patch
series one more time carefully and did not find anything additional in
need of correction. So here is V4.

Add support for the MinnowBoard in the pch_gbe driver. This was
originally sent to LKML as part of the MinnowBoard support series. That
is now partially merged and this version of the patch has been isolated
from those changes and is now completely self-contained.

Thanks to everyone on Cc for their time in reviewing, the patch series
is better for it.

V2:
  Whitespace cleanup
  Remove trailing period in messages
  Comment formatting (added a colon)
  Use devm_gpio_request_one
  Fix missing adapter->pdata NULL check in PHY
  Use netdev style comment blocks
  Use kernel_ulong_t for driver_data cast
  Use unsigned for gpio and unsigned long for flags
V3:
  Restore /** comment start for file consistency per Joe Perches
    following his checkpatch.pl patch
  Make pch_gbe_phy_tx_clk_delay() static per David Miller
V4:
  Add space in function pointer declaration per Andy Shevchenko
  Remove unnecessary inclusion of mod_devicetable.h per Andy Shevchenko

The following changes since commit 18afa4b028b46f8b45ca64f94aefe717c297b07d:

  net: Make devnet_rename_seq static (2013-07-24 17:57:26 -0700)

are available in the git repository at:

  git://git.infradead.org/users/dvhart/linux-2.6.git minnow/net-next
  ssh://git.infradead.org/srv/git/users/dvhart/linux-2.6.git minnow/net-next

and browsable here:

  http://git.infradead.org/users/dvhart/linux-2.6.git/shortlog/refs/heads/minnow/net-next

Darren Hart (2):
  pch_gbe: Use PCH_GBE_PHY_REGS_LEN instead of 32
  pch_gbe: Add MinnowBoard support

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 15 ++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 51 ++++++++++-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 98 ++++++++++++++++++++++
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  1 +
 4 files changed, 164 insertions(+), 1 deletion(-)

-- 
1.8.3.1
