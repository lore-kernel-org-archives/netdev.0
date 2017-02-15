From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 00/13] net: ethernet: aquantia: improvements and fixes
Date: Wed, 15 Feb 2017 23:01:08 +0300
Message-ID: <cover.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0049.outbound.protection.outlook.com ([104.47.34.49]:65264
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750791AbdBOUCq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:02:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

The following patchset contains improvements and fixes for aQuantia
AQtion ethernet driver from net-next tree.

Most fixes are based on the comments from Lino Sanfilippo.

Sanity testing was performed on real HW.

Please review.
Thanks.


Pavel Belous (13):
  net: ethernet: aquantia: Removed extra assignment for skb->dev.
  net: ethernet: aquantia: Removed busy_count field.
  net: ethernet: aquantia: Removed unnecessary comparsion "old_mtu ==
    new_mtu".
  net: ethernet: aquantia: Using module_pci_driver.
  net: ethernet: aquantia: Superfluous initialization of "err".
  net: ethernet: aquantia: Fixed missing rtnl_unlock.
  net: ethernet: aquantia: Using NETDEV_TX_OK instead 0.
  net: ethernet: aquantia: Null pointer check for aq_nic_ndev_alloc.
  net: ethernet: aquantia: Call netdev_register after all initialized.
  net: ethernet: aquantia: Checking for success dma_map_single.
  net: ethernet: aquantia: Refactoring buffers copying.
  net: ethernet: aquantia: Fixed incorrect buff->len calculation.
  net: ethernet: aquantia: Fixed memory allocation if
    AQ_CFG_RX_FRAME_MAX > 1 page.

 drivers/net/ethernet/aquantia/atlantic/aq_main.c   | 34 ++------------
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 52 +++++++++++-----------
 drivers/net/ethernet/aquantia/atlantic/aq_ring.c   | 30 +++++++------
 drivers/net/ethernet/aquantia/atlantic/aq_utils.h  |  1 -
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c  |  4 +-
 .../ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c  |  4 +-
 6 files changed, 50 insertions(+), 75 deletions(-)

-- 
2.7.4
