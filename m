From: Neill Whillans <neill.whillans@codethink.co.uk>
Subject: [PATCH 0/2] net: Add support for SGMII PCS on Altera TSE MAC
Date: Wed, 30 Nov 2016 13:41:03 +0000
Message-ID: <cover.1480497966.git.neill.whillans@codethink.co.uk>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@lists.codethink.co.uk,
        nios2-dev@lists.rocketboards.org, vbridger@opensource.altera.com,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches were created as part of work to add support for SGMII
PCS functionality to the Altera TSE MAC. Patches are based on 4.9-rc6
git tree.

The first patch in the series adds support for the VSC8572 dual-port
Gigabit Ethernet transceiver, used in integration testing.

The second patch adds support for the SGMII PCS functionality to the
Altera TSE driver.

 
Neill Whillans (1):
  net: ethernet: altera_tse: add support for SGMII PCS

Stephen Agate (1):
  net: phy: vitesse: add support for VSC8572

 drivers/net/ethernet/altera/altera_tse.h      | 11 ++++
 drivers/net/ethernet/altera/altera_tse_main.c | 91 +++++++++++++++++++++++++++
 drivers/net/phy/vitesse.c                     | 14 +++++
 3 files changed, 116 insertions(+)

-- 
2.1.4
