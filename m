From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net V2 0/4] mlx4 fixes
Date: Sun, 11 Sep 2016 10:56:16 +0300
Message-ID: <1473580580-2323-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41788 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752463AbcIKH4x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 03:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains several bug fixes from the team to the
mlx4 Eth driver.

Series generated against net commit:
c2f57fb97da5 "drivers: net: phy: mdio-xgene: Add hardware dependency"

Thanks,
Tariq.

v2:
* excluded some cleanup patches.

Kamal Heib (2):
  net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_all()
  net/mlx4_en: Fix the return value of mlx4_en_dcbnl_set_state()

Moshe Shemesh (1):
  net/mlx4_en: Fix panic on xmit while port is down

Tariq Toukan (1):
  net/mlx4_en: Fixes for DCBX

 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c | 57 ++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 21 ++++------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 12 +++---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   | 15 ++-----
 drivers/net/ethernet/mellanox/mlx4/port.c      |  4 +-
 5 files changed, 50 insertions(+), 59 deletions(-)

-- 
1.8.3.1
