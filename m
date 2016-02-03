From: Alexandre TORGUE <alexandre.torgue@gmail.com>
Subject: [PATCH 0/4]  Add Ethernet support on STM32F429
Date: Wed,  3 Feb 2016 15:54:31 +0100
Message-ID: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
This series:
	-enhance current stmmac driver to control it (code already available) and 
	 adds basic glue for STM32F429 chip.
	-Enable basic Net config in kernel.

Note that DT patches are not present because STM32 pinctrl code is not
yet avalaible.

Regards 

Alexandre

Alexandre TORGUE (4):
  net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
  Documentation: Bindings: Add STM32 DWMAC glue
  net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP
  ARM: STM32: Enable Ethernet in stm32_defconfig

 .../devicetree/bindings/net/stm32-dwmac.txt        |  41 +++++
 arch/arm/configs/stm32_defconfig                   |   9 ++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 177 +++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
 6 files changed, 241 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/stm32-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c

-- 
1.9.1
