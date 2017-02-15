From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 0/8] misc patchs
Date: Wed, 15 Feb 2017 10:46:37 +0100
Message-ID: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello

This is a follow up of my previous stmmac serie which address some comment
done in v2.

Corentin Labbe (8):
  net: stmmac: remove useless parenthesis
  net: stmmac: likely is useless in occasional function
  net: stmmac: use SPEED_UNKNOWN/DUPLEX_UNKNOWN
  net: stmmac: set speed at SPEED_UNKNOWN in case of broken speed
  net: stmmac: run stmmac_hw_fix_mac_speed when speed is valid
  net: stmmac: split the stmmac_adjust_link 10/100 case
  net: stmmac: reduce indentation by adding a continue
  net: stmmac: invert the logic for dumping regs

 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   | 18 ++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 40 ++++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 82 +++++++++++-----------
 3 files changed, 71 insertions(+), 69 deletions(-)

-- 
2.10.2
