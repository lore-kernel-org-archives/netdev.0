From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH v4 0/6] stmmac: pci: Refactor DMI probing
Date: Fri,  2 Jun 2017 09:34:48 +0200
Message-ID: <cover.1496388893.git.jan.kiszka@siemens.com>
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

Changes in v4:
 - Refactor patch 5 according to feedback

Jan

Jan Kiszka (6):
  stmmac: pci: Make stmmac_pci_info structure constant
  stmmac: pci: Use stmmac_pci_info for all devices
  stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
  stmmac: pci: Select quark_pci_dmi_data from quark_default_data
  stmmac: pci: Use dmi_system_id table for retrieving PHY addresses
  stmmac: pci: Remove setup handler indirection via stmmac_pci_info

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 205 +++++++++++++----------
 1 file changed, 119 insertions(+), 86 deletions(-)

-- 
2.12.3
