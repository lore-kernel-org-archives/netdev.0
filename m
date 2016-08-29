From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH v6 0/3] Add Ethernet support on STM32F429
Date: Mon, 29 Aug 2016 18:23:37 +0200
Message-ID: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh@kernel.org>, <manabian@gmail.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:48352 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751190AbcH2QYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

STM32F429 Chip embeds a Synopsys 3.50a MAC IP.

This series enhance current stmmac driver to control it (code already
available) and adds basic glue for STM32F429 chip.

Changes since v5:
 -Fix typo in bindings documentation patch.
 -Change clocks names in stm32-dwmac glue driver / Documentation.
 -After rebase, stm32 ethernet node is now available. It has to be updated
according to new clocks names.

Changes since v4:
 -Fix dirty copy/past in bindings documentation patch.

Changes since v3:
 -Fix "tx-clk" and "rx-clk" as required clocks. Driver and bindings are
modified.

Changes since v2:
 -Fix alphabetic order in Kconfig and Makefile.
 -Improve code according to Joachim review.
 -Binding: remove useless entry.

Changes since v1:
 -Fix Kbuild issue in Kconfig.
 -Remove init/exit callbacks. Suspend/Resume and remove driver is no more
driven in stmmac_pltfr but directly in dwmac-stm32 glue driver.
 -Take into account Joachim review.

Regards.

Alexandre.

Alexandre TORGUE (3):
  net: ethernet: dwmac: add Ethernet glue logic for stm32 chip
  Documentation: Bindings: Add STM32 DWMAC glue
  net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP

 .../devicetree/bindings/net/stm32-dwmac.txt        |  32 ++++
 drivers/net/ethernet/stmicro/stmmac/Kconfig        |  12 ++
 drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 193 +++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   1 +
 5 files changed, 239 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/stm32-dwmac.txt
 create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c

-- 
1.9.1
