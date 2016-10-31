From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 0/2] net: stmmac: Add OXNAS DWMAC Glue
Date: Mon, 31 Oct 2016 11:53:43 +0100
Message-ID: <20161031105345.16711-1-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>, netdev@vger.kernel.org,
        linux-oxnas@lists.tuxfamily.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset add support for the Sysnopsys DWMAC Gigabit Ethernet
controller Glue layer of the Oxford Semiconductor OX820 SoC.

Changes since v1 at https://patchwork.kernel.org/patch/9388231/ :
 - Split dt-bindings in a separate patch
 - Add IP version in the dt-bindings compatible
 - Check return of clk_prepare_enable()
 - use get_stmmac_bsp_priv() helper
 - hardwire setup values in oxnas_dwmac_init()

Changes since RFC at https://patchwork.kernel.org/patch/9387257 :
 - Drop init/exit callbacks
 - Implement proper remove and PM callback
 - Call init from probe
 - Disable/Unprepare clock if stmmac probe fails

Neil Armstrong (2):
  net: stmmac: Add OXNAS Glue Driver
  dt-bindings: net: Add OXNAS DWMAC Bindings

 .../devicetree/bindings/net/oxnas-dwmac.txt        |  39 ++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c  | 215 +++++++++++++++++++++
 4 files changed, 266 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c

-- 
2.7.0
