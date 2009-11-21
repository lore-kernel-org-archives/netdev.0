From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/23] e1000e: add missing tests for 82583 in
	ethtool functions
Date: Sat, 21 Nov 2009 01:22:20 -0800
Message-ID: <20091121092219.5715.85151.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:46580 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751766AbZKUJWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:22:31 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Add tests for 82583 in a couple ethtool functions that were missed from the
initial hardware enablement submission.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ethtool.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 3af5ee4..1ff43b4 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -604,7 +604,9 @@ static int e1000_set_eeprom(struct net_device *netdev,
 	 * and flush shadow RAM for applicable controllers
 	 */
 	if ((first_word <= NVM_CHECKSUM_REG) ||
-	    (hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82573))
+	    (hw->mac.type == e1000_82583) ||
+	    (hw->mac.type == e1000_82574) ||
+	    (hw->mac.type == e1000_82573))
 		ret_val = e1000e_update_nvm_checksum(hw);
 
 out:
@@ -1839,6 +1841,7 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 
 	if ((hw->phy.type == e1000_phy_ife) ||
 	    (hw->mac.type == e1000_pchlan) ||
+	    (hw->mac.type == e1000_82583) ||
 	    (hw->mac.type == e1000_82574)) {
 		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 		if (!adapter->blink_timer.function) {

