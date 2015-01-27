From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v3 0/3] net: stmmac: Enable Intel Quark SoC X1000 Ethernet support
Date: Tue, 27 Jan 2015 21:44:46 +0200
Message-ID: <1422387889-21559-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7495 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759476AbbA0TpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 14:45:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is third version of the patch series [1] to bring network card support to
Intel Quark SoC.

The series has been tested on Intel Galileo board.

Changelog v3:
 - rebase on top of recent net-next
 - rework an approach to get the custom configuration
 - rework an approach how to get unique bus_id
 - improve DMI lookup function

[1] http://www.spinics.net/lists/netdev/msg296010.html

Andy Shevchenko (1):
  stmmac: pci: introduce Intel Quark X1000 runtime detection

Kweh, Hock Leong (2):
  stmmac: pci: add support for Intel Quark X1000
  stmmac: pci: add MSI support for Intel Quark X1000

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 113 ++++++++++++++++++++++-
 1 file changed, 112 insertions(+), 1 deletion(-)

-- 
2.1.4
