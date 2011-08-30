From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 0/9] update the stmmac to the version Aug_2011 (v2)
Date: Tue, 30 Aug 2011 16:20:55 +0200
Message-ID: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:43176 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753257Ab1H3OVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:16 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id E4C2DC7
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:13 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 812052273
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:13 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches update the driver adding new supports:
MMC (HW management counters), HW feature register and
debugfs support.

MMC counters are exposed via ethtool.

These also update the documentation adding a new section
for the debugging.

Deepak Sikri (1):
  stmmac: support wake up irq from external sources

Giuseppe Cavallaro (8):
  stmmac: remove the STBus bridge setting from the GMAC code
  stmmac: remove the mmc code
  stmmac: add MMC support exported via ethtool
  stmmac: export DMA TX/RX rings via debugfs.
  stmmac: rework the code to get the Synopsys ID
  stmmac: add HW DMA feature register
  stmmac: update the doc with new info about the driver's debug.
  stmmac: update the driver version (Aug_2011)

 Documentation/networking/stmmac.txt |   33 ++++-
 drivers/net/stmmac/Kconfig          |    8 +
 drivers/net/stmmac/Makefile         |    3 +-
 drivers/net/stmmac/common.h         |   46 +++++--
 drivers/net/stmmac/dwmac1000_core.c |   11 +-
 drivers/net/stmmac/dwmac1000_dma.c  |   14 +-
 drivers/net/stmmac/dwmac100_core.c  |   12 +--
 drivers/net/stmmac/dwmac_dma.h      |    1 +
 drivers/net/stmmac/mmc.h            |  131 ++++++++++++++++
 drivers/net/stmmac/mmc_core.c       |  265 ++++++++++++++++++++++++++++++++
 drivers/net/stmmac/stmmac.h         |    5 +-
 drivers/net/stmmac/stmmac_ethtool.c |  149 ++++++++++++++++--
 drivers/net/stmmac/stmmac_main.c    |  287 ++++++++++++++++++++++++++++++++++-
 13 files changed, 901 insertions(+), 64 deletions(-)
 create mode 100644 drivers/net/stmmac/mmc.h
 create mode 100644 drivers/net/stmmac/mmc_core.c

-- 
1.7.4.4
