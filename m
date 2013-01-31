From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v3 0/2] Add CPSW VLAN Support
Date: Fri, 1 Feb 2013 00:33:18 +0530
Message-ID: <1359659000-25995-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CPSW is capable of filtering VLAN packets in hardware. This patch series
implements VLAN support to CPSW driver.
This patch series is tested on net-next with AM335x EVM with ping test.

Changes from initial version
* added vlan support to existing add/delete unicast/multicast apis
* Made driver as default VLAN enabled so that drivers need to be recompiled
  when stack is compiled with VLAN

Changes from V2
* Moved repeated code to static inline function
* Made vlan add/delete function return type to void as it is not used in
  the current driver implementation
* Modified cpsw_add_default_vlan for better readability
* changed BIT(1) port representation to defines

Mugunthan V N (2):
  drivers: net: cpsw: Add helper functions for VLAN ALE implementation
  drivers: net:ethernet: cpsw: add support for VLAN

 Documentation/devicetree/bindings/net/cpsw.txt |    2 +
 drivers/net/ethernet/ti/cpsw.c                 |   93 +++++++++++++++++++--
 drivers/net/ethernet/ti/cpsw_ale.c             |  105 +++++++++++++++++++++---
 drivers/net/ethernet/ti/cpsw_ale.h             |   24 ++++--
 include/linux/platform_data/cpsw.h             |    1 +
 5 files changed, 201 insertions(+), 24 deletions(-)

-- 
1.7.9.5

