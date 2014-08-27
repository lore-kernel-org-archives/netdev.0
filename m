From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH 0/4] net: stmmac: Enable Intel Quark SoC X1000 Ethernet support
Date: Wed, 27 Aug 2014 18:32:25 +0800
Message-ID: <cover.1409123378.git.hock.leong.kweh@intel.com>
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ong Boon Leong <boon.leong.ong@intel.com>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56120 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933374AbaH0Kbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 06:31:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

Hi,

Intel Quark X1000 SoC has 2 Ethernet controllers integrated on chip and they are
PCI devices. We adopted the stmmac_pci driver and added on code to support Intel
Quark SoC X1000 by creating the patchset below. The patchset has been built and
tested on Galileo board and found to be working as expected.

We believe that the changes are transparent to other non Intel Quark platform. 
Please help to review the code change and feedback if there is any concern.

Thank you very much.

Kweh, Hock Leong (4):
  net: stmmac: enhance to support multiple device instances
  net: stmmac: better code manageability with platform data struct
  net: stmmac: add support for Intel Quark X1000
  net: stmmac: add MSI support for Intel Quark X1000

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |  195 +++++++++++++++++++---
 1 file changed, 172 insertions(+), 23 deletions(-)

-- 
1.7.9.5
