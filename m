From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 3/9] net: fix trivial typos
Date: Sun, 18 Oct 2015 23:31:09 +0800
Message-ID: <5fea4cd474d5fe49688f88d91cdf5e8019844806.1445181079.git.geliangtang@163.com>
References: <949f6f3c99f87b57666986dc9f2d1c916935e215.1445181079.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <949f6f3c99f87b57666986dc9f2d1c916935e215.1445181079.git.geliangtang@163.com>
In-Reply-To: <557286dd38beb4d8d1be28e787ad89611e7cc077.1445181079.git.geliangtang@163.com>
References: <949f6f3c99f87b57666986dc9f2d1c916935e215.1445181079.git.geliangtang@163.com> <557286dd38beb4d8d1be28e787ad89611e7cc077.1445181079.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

s/regsiter/register/

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/ethernet/amd/amd8111e.h           | 2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c | 2 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c    | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
index 7cdb185..d5e2b71 100644
--- a/drivers/net/ethernet/amd/amd8111e.h
+++ b/drivers/net/ethernet/amd/amd8111e.h
@@ -48,7 +48,7 @@ eg., if the value 10011010b is written into the least significant byte of a comm
 /* 32 bit registers */
 
 #define  ASF_STAT		0x00	/* ASF status register */
-#define CHIPID			0x04	/* Chip ID regsiter */
+#define CHIPID			0x04	/* Chip ID register */
 #define	MIB_DATA		0x10	/* MIB data register */
 #define MIB_ADDR		0x14	/* MIB address register */
 #define STAT0			0x30	/* Status0 register */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index a8b80c5..73efdb0 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -307,7 +307,7 @@ void atl1c_start_phy_polling(struct atl1c_hw *hw, u16 clk_sel)
 
 /*
  * atl1c_read_phy_core
- * core function to read register in PHY via MDIO control regsiter.
+ * core function to read register in PHY via MDIO control register.
  * ext: extension register (see IEEE 802.3)
  * dev: device address (see IEEE 802.3 DEVAD, PRTAD is fixed to 0)
  * reg: reg to read
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 23ec28f..ffc3a14 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -123,7 +123,7 @@ out:
  *  @offset: register offset to be read
  *  @data: pointer to the read data
  *
- *  Reads the MDI control regsiter in the PHY at offset and stores the
+ *  Reads the MDI control register in the PHY at offset and stores the
  *  information read to data.
  **/
 s32 igb_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
-- 
2.5.0
