From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 0/9] update the stmmac to the version Aug_2011 (v3)
Date: Fri,  2 Sep 2011 09:51:34 +0200
Message-ID: <1314949903-26137-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:38335 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757770Ab1IBHwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 03:52:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches update the driver adding new supports:
MMC (HW management counters), HW feature register and
debugfs support.

MMC counters are exposed via ethtool.

These also update the documentation adding a new section
for the debugging.

Deepak Sikri (1):
  stmmac: support wake up irq from external sources (v3)

Giuseppe Cavallaro (8):
  stmmac: remove the STBus bridge setting from the GMAC code (v3)
  stmmac: remove the mmc code (v3)
  stmmac: add MMC support exported via ethtool (v3)
  stmmac: export DMA TX/RX rings via debugfs (v3)
  stmmac: rework the code to get the Synopsys ID (v3)
  stmmac: add HW DMA feature register (v3)
  stmmac: update the doc with new info about the driver's debug (v3)
  stmmac: update the driver version (Aug_2011) (v3)

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
 drivers/net/stmmac/stmmac_ethtool.c |  144 ++++++++++++++++--
 drivers/net/stmmac/stmmac_main.c    |  287 ++++++++++++++++++++++++++++++++++-
 13 files changed, 897 insertions(+), 63 deletions(-)
 create mode 100644 drivers/net/stmmac/mmc.h
 create mode 100644 drivers/net/stmmac/mmc_core.c

-- 
1.7.4.4
