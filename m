From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH 0/4] STM32F429: Add Ethernet fixes
Date: Thu, 20 Oct 2016 17:21:22 +0200
Message-ID: <1476976886-23781-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <devicetree@vger.kernel.org>
To: <peppe.cavallaro@st.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>, <arnd@arndb.de>,
        <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:38408 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964884AbcJTPWS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 11:22:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds several fixes for Ethernet for stm32f429 MCU.
First 2 patches have already been reviewed some months ago when 
stm32 Ethernet glue has been pushed (I added in this series to keep
history). Fixes are:
 -Change DT to be compliant to stm32 ethernet glue binding
 -Add phy-handle to correctly use mdio subnode
 -Remove WoL support

Regards

Alex


Alexandre TORGUE (4):
  ARM: dts: stm32f429: Align Ethernet node with new bindings properties
  ARM: dts: stm32f429: Update Ethernet node on Eval board
  ARM: dts: stm32f429: Fix Ethernet node on Eval Board
  ARM: dts: stm32f429: remove Ethernet wake on Lan support

 arch/arm/boot/dts/stm32429i-eval.dts |  7 ++++---
 arch/arm/boot/dts/stm32f429.dtsi     | 10 +++++-----
 2 files changed, 9 insertions(+), 8 deletions(-)

-- 
1.9.1
