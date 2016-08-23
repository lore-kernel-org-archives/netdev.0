From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] ixgbe: Fix non static symbol warnings
Date: Tue, 23 Aug 2016 15:07:22 +0000
Message-ID: <1471964842-335-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36040 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcHWPH7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:07:59 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so8427950pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:07:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warnings:

drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2128:5: warning:
 symbol 'ixgbe_led_on_t_x550em' was not declared. Should it be static?
drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2150:5: warning:
 symbol 'ixgbe_led_off_t_x550em' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index fb1b819..417913e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2125,7 +2125,7 @@ static s32 ixgbe_reset_phy_t_X550em(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *  @led_idx: led number to turn on
  **/
-s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
+static s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
 {
 	u16 phy_data;
 
@@ -2147,7 +2147,7 @@ s32 ixgbe_led_on_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
  *  @hw: pointer to hardware structure
  *  @led_idx: led number to turn off
  **/
-s32 ixgbe_led_off_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
+static s32 ixgbe_led_off_t_x550em(struct ixgbe_hw *hw, u32 led_idx)
 {
 	u16 phy_data;
 
