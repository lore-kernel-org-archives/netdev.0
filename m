From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 0/4] stmmac: pci: various cleanups and fixes
Date: Wed,  5 Nov 2014 12:27:25 +0200
Message-ID: <1415183249-9231-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47404 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754485AbaKEK1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 05:27:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are few cleanups and fixes regarding to stmmac PCI driver.
This has been tested on Intel Galileo board with recent net-next tree.

Since v2:
- drop patch 5/5 since it will be part of a big change across entire subsystem

Since v1:
- remove already applied patch
- append patch 1/5
- rework patch 3/5 to be functional compatible with original code

Andy Shevchenko (4):
  stmmac: pci: use defined constant instead of magic number
  stmmac: pci: convert to use dev_pm_ops
  stmmac: pci: use managed resources
  stmmac: pci: convert to use dev_* macros

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 80 ++++++++----------------
 1 file changed, 26 insertions(+), 54 deletions(-)

-- 
2.1.1
