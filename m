From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH 0/2] net: stmmac: phy logging fixes
Date: Mon, 21 Aug 2017 09:52:33 +0200
Message-ID: <20170821075235.28473-1-romain.perier@collabora.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches fixes issues related to logging. First it delete old
code that is no longer used in stmmac_mdio_register(). Then, it fixes a
crash that happens when phydev->drv is NULL and phy_attached_info() is
called prior phy_driver is binded to phydev.

Romain Perier (2):
  net: stmmac: Delete dead code for MDIO registration
  net: phy: Don't use drv when it is NULL in phy_attached_info

 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 16 ----------------
 drivers/net/phy/phy_device.c                      | 13 +++++++++++--
 2 files changed, 11 insertions(+), 18 deletions(-)

-- 
2.11.0
