From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 00/10] stmmac update: March 2012 (v2)
Date: Wed,  4 Apr 2012 16:33:18 +0200
Message-ID: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, deepak.sikri@st.com, spear-devel@list.st.com,
	shiraz.hashim@st.com, viresh.kumar@st.com,
	srinivas.kandagatla@st.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:55405 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756546Ab2DDOeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 10:34:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches  update the stmmac and add all the work made
by Deepak, Srinivas and myself.

This is the version two of these patch series where I reviewed
some part of the code after some comments and advice, for example
the IPC setting and the broken 250MHz define... Thx Deepak and David.

On-Top of these patches (for net-next) I'll resend the EEE support
reviewed by Ben.

Peppe

P.S.    I maintained the version as March 2012... I'll update it
	as soon as EEE is added and other fixes provided (for
	example I'm working to extend perfect filtering for
	unicast).

Deepak SIKRI (5):
  stmmac: Define CSUM offload engine Types
  stmmac: sanitize the rx coe and add the type-1 csum (v2)
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
 drivers/net/ethernet/stmicro/stmmac/common.h       |   19 +++-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |    2 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    4 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   42 +++++++-
 .../net/ethernet/stmicro/stmmac/dwmac100_core.c    |   12 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    6 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h    |    1 +
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     |   13 ++-
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   13 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |   48 ++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  109 +++++++++++++++++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   36 +++++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    3 +-
 include/linux/stmmac.h                             |   55 ++++++++++-
 15 files changed, 335 insertions(+), 57 deletions(-)

-- 
1.7.4.4
