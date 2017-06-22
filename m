From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v5 0/5] stmmac: pci: Refactor DMI probing
Date: Thu, 22 Jun 2017 08:17:56 +0200
Message-ID: <cover.1498112281.git.jan.kiszka@siemens.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andy.shevchenko@gmail.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some cleanups of the way we probe DMI platforms in the driver. Reduces
a bit of open-coding and makes the logic easier reusable for any
potential DMI platform != Quark.

Tested on IOT2000 and Galileo Gen2.

Changes in v5:
 - fixed a remaining issue in patch 5
 - dropped patch 6 for now

Jan

Jan Kiszka (5):
  stmmac: pci: Make stmmac_pci_info structure constant
  stmmac: pci: Use stmmac_pci_info for all devices
  stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
  stmmac: pci: Select quark_pci_dmi_data from quark_default_data
  stmmac: pci: Use dmi_system_id table for retrieving PHY addresses

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 203 ++++++++++++++---------
 1 file changed, 122 insertions(+), 81 deletions(-)

-- 
2.12.3
