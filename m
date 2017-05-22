From: Jan Kiszka <jan.kiszka@siemens.com>
Subject: [PATCH 0/3] stmmac: pci: Refactor DMI probing
Date: Mon, 22 May 2017 13:12:06 +0200
Message-ID: <cover.1495451529.git.jan.kiszka@siemens.com>
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

Jan

Jan Kiszka (3):
  stmmac: pci: Overcome stmmac_pci_info structure
  stmmac: pci: Make stmmac_pci_find_phy_addr truly generic
  stmmac: pci: Use dmi_system_id table for retrieving PHY addresses

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 184 ++++++++++++-----------
 1 file changed, 99 insertions(+), 85 deletions(-)

-- 
2.12.0
