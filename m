From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 22/23] e1000e: cosmetic - group local variables
	of the same type
Date: Sat, 21 Nov 2009 01:28:37 -0800
Message-ID: <20091121092836.5715.2628.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:48967
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752761AbZKUJ2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:28:48 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |   11 +++--------
 drivers/net/e1000e/es2lan.c  |    6 ++----
 drivers/net/e1000e/ich8lan.c |    8 ++++----
 3 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 474f4e4..62bbc6e 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -693,8 +693,7 @@ static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 				      u16 words, u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
-	u32 i;
-	u32 eewr = 0;
+	u32 i, eewr = 0;
 	s32 ret_val = 0;
 
 	/*
@@ -829,10 +828,7 @@ static s32 e1000_set_d0_lplu_state_82571(struct e1000_hw *hw, bool active)
  **/
 static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 {
-	u32 ctrl;
-	u32 extcnf_ctrl;
-	u32 ctrl_ext;
-	u32 icr;
+	u32 ctrl, extcnf_ctrl, ctrl_ext, icr;
 	s32 ret_val;
 	u16 i = 0;
 
@@ -941,8 +937,7 @@ static s32 e1000_init_hw_82571(struct e1000_hw *hw)
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 reg_data;
 	s32 ret_val;
-	u16 i;
-	u16 rar_count = mac->rar_entry_count;
+	u16 i, rar_count = mac->rar_entry_count;
 
 	e1000_initialize_hw_bits_82571(hw);
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 6ba1228..e505798 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -695,8 +695,7 @@ static s32 e1000_get_cable_length_80003es2lan(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val;
-	u16 phy_data;
-	u16 index;
+	u16 phy_data, index;
 
 	ret_val = e1e_rphy(hw, GG82563_PHY_DSP_DISTANCE, &phy_data);
 	if (ret_val)
@@ -746,8 +745,7 @@ static s32 e1000_get_link_up_info_80003es2lan(struct e1000_hw *hw, u16 *speed,
  **/
 static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 {
-	u32 ctrl;
-	u32 icr;
+	u32 ctrl, icr;
 	s32 ret_val;
 
 	/*
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index f991b14..568bb25 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -706,7 +706,9 @@ static void e1000_release_swflag_ich8lan(struct e1000_hw *hw)
  **/
 static bool e1000_check_mng_mode_ich8lan(struct e1000_hw *hw)
 {
-	u32 fwsm = er32(FWSM);
+	u32 fwsm;
+
+	fwsm = er32(FWSM);
 
 	return (fwsm & E1000_FWSM_MODE_MASK) ==
 		(E1000_ICH_MNG_IAMT_MODE << E1000_FWSM_MODE_SHIFT);
@@ -2349,9 +2351,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 	u32 flash_bank_size = nvm->flash_bank_size * 2;
 	s32 ret_val;
 	s32 count = 0;
-	s32 iteration;
-	s32 sector_size;
-	s32 j;
+	s32 j, iteration, sector_size;
 
 	hsfsts.regval = er16flash(ICH_FLASH_HSFSTS);
 

