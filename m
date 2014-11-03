From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 0/5]  stmmac: pci: various cleanups and fixes
Date: Mon,  3 Nov 2014 15:02:12 +0200
Message-ID: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56050 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711AbaKCNCW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 08:02:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are few cleanups and fixes regarding to stmmac PCI driver.
This has been tested on Intel Galileo board with recent net-next tree.

Since v1:
- remove already applied patch
- append patch 1/5
- rework patch 3/5 to be functional compatible with original code

Andy Shevchenko (5):
  stmmac: pci: use defined constant instead of magic number
  stmmac: pci: convert to use dev_pm_ops
  stmmac: pci: use managed resources
  stmmac: pci: convert to use dev_* macros
  stmmac: pci: remove FSF address

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 84 ++++++++----------------
 1 file changed, 26 insertions(+), 58 deletions(-)

-- 
2.1.1
