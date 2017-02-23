From: Thierry Reding <thierry.reding@gmail.com>
Subject: [PATCH 0/7] net: stmmac: Fixes and Tegra186 support
Date: Thu, 23 Feb 2017 18:24:31 +0100
Message-ID: <20170223172438.14770-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Alexandre Courbot <gnurou@gmail.com>,
        Jon Hunter <jonathanh@nvidia.com>, netdev@vger.kernel.org,
        linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding@nvidia.com>

Hi everyone,

This series of patches start with a few cleanups that I ran across while
adding Tegra186 support to the stmmac driver. It then adds code for FIFO
size parsing from feature registers and finally enables support for the
incarnation of the Synopsys DWC QOS IP found on NVIDIA Tegra186 SoCs.

This is based on next-20170223.

Thanks,
Thierry

Thierry Reding (7):
  net: stmmac: Rename clk_ptp_ref clock to ptp_ref
  net: stmmac: Balance PTP reference clock enable/disable
  net: stmmac: Check for DMA mapping errors
  net: stmmac: Parse FIFO sizes from feature registers
  net: stmmac: Program RX queue size and flow control
  net: stmmac: dwc-qos: Split out ->probe() and ->remove()
  net: stmmac: dwc-qos: Add Tegra186 support

 Documentation/devicetree/bindings/net/stmmac.txt   |   6 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +
 .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 366 +++++++++++++++++++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  12 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   |  45 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   9 +
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   3 +-
 7 files changed, 411 insertions(+), 33 deletions(-)

-- 
2.11.1
