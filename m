From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 0/5] stmmac: pci: various cleanups and fixes
Date: Tue, 21 Oct 2014 19:35:28 +0300
Message-ID: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6978 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932769AbaJUQpE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 12:45:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are few cleanups and fixes regarding to stmmac PCI driver.
This has been tested on Intel Galileo board with 3.18-rc1 kernel.

Andy Shevchenko (5):
  stmmac: pci: convert to use dev_pm_ops
  stmmac: pci: use managed resources
  stmmac: pci: convert to use dev_* macros
  stmmac: pci: set default filter bins
  stmmac: pci: remove FSF address

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 92 ++++++++----------------
 1 file changed, 30 insertions(+), 62 deletions(-)

-- 
2.1.1
