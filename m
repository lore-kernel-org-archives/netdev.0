From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 0/9] update the stmmac to the version Aug_2011
Date: Thu, 25 Aug 2011 10:00:20 +0200
Message-ID: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:57740 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750952Ab1HYIAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:00:43 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5F661124
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:00:36 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9B96116C5
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:00:36 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches update the driver adding new supports:
MMC (HW management counters), HW feature register and
debugfs support.

These also update the documentation adding a new section
for the debugging.

Deepak Sikri (1):
  stmmac: support wake up irq from external sources

Giuseppe Cavallaro (8):
  stmmac: remove the STBus bridge setting from the GMAC code
  stmmac: remove the mmc code
  stmmac: add MMC supports exported via debugfs.
  stmmac: export DMA TX/RX rings via debugfs.
  stmmac: rework the code to get the Synopsys ID
  stmmac: add HW DMA feature register
  stmmac: update the doc with new info about the driver's debug.
  stmmac: update the driver version (Aug_2011)

 Documentation/networking/stmmac.txt |   39 +++-
 drivers/net/stmmac/Kconfig          |   10 +
 drivers/net/stmmac/Makefile         |    3 +-
 drivers/net/stmmac/common.h         |   45 +++-
 drivers/net/stmmac/dwmac1000_core.c |   11 +-
 drivers/net/stmmac/dwmac1000_dma.c  |    6 +
 drivers/net/stmmac/dwmac100_core.c  |   12 +-
 drivers/net/stmmac/dwmac_dma.h      |    1 +
 drivers/net/stmmac/mmc.h            |  131 +++++++++
 drivers/net/stmmac/mmc_core.c       |  265 ++++++++++++++++++
 drivers/net/stmmac/stmmac.h         |    6 +-
 drivers/net/stmmac/stmmac_ethtool.c |    4 +-
 drivers/net/stmmac/stmmac_main.c    |  515 ++++++++++++++++++++++++++++++++++-
 13 files changed, 1005 insertions(+), 43 deletions(-)
 create mode 100644 drivers/net/stmmac/mmc.h
 create mode 100644 drivers/net/stmmac/mmc_core.c

-- 
1.7.4.4
