From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] e1000: fix kernel-doc argument being missing
Date: Sun, 13 Dec 2015 00:31:23 -0800
Message-ID: <1449995490-17020-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:34868 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751435AbbLMIlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:41:01 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

Due to historical reason, 'phy_data' has never been included in the
kernel doc. Fix it so that the requirement could be fulfilled.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 59d1769..dbae55e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -2806,6 +2806,7 @@ static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
  * e1000_read_phy_reg - read a phy register
  * @hw: Struct containing variables accessed by shared code
  * @reg_addr: address of the PHY register to read
+ * @phy_data: pointer to the value on the PHY register
  *
  * Reads the value from a PHY register, if the value is on a specific non zero
  * page, sets the page first.
-- 
2.5.0
