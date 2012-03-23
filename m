From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 00/10] stmmac update: March 2012
Date: Fri, 23 Mar 2012 10:08:31 +0100
Message-ID: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, srinivas.kandagatla@st.com,
	deepak.sikri@st.com, spear-devel@list.st.com, shiraz.hashim@st.com,
	viresh.kumar@st.com, bhutchings@solarflare.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:36110 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757838Ab2CWJJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 05:09:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches  update the stmmac and add all the work made
by Deepak, Srinivas and myself.

I've collected all the patches already reviewed in the mailing list
verified that all the comments provided were applied and tested them.

These patches can be applied against the net.git and net-next.git.

On-Top of these patches (for net-next) I'll resend the EEE support
reviewed by Ben.

Many thanks for all your effort and patience.

---
peppe

Deepak SIKRI (5):
  stmmac: Define CSUM offload engine Types
  stmmac: sanitize the rx coe and add the type-1 csum
  stmmac: Define MDC clock selection macros
  stmmac: re-work the internal GMAC DMA platf parameters
  stmmac: Replace infinite loops by timeouts in mdio r/w

Giuseppe Cavallaro (4):
  stmmac: add clk management support
  stmmac: extend CSR Clock Range programming
  stmmac: MDC clock dynamically based on the csr clock input
  stmmac: update the driver version March 2012

Srinivas Kandagatla (1):
  stmmac: Allow stmmac to work with other PHY buses(v3).

 Documentation/networking/stmmac.txt                |   29 +++++-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   17 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |   13 ---
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   42 +++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |    6 -
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    6 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   13 ++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   13 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   48 +++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  101 +++++++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   36 +++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    3 +-
 include/linux/stmmac.h                             |   55 +++++++++++-
 15 files changed, 317 insertions(+), 68 deletions(-)

-- 
1.7.4.4
