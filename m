From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/3] mlx4_en num of rings
Date: Tue, 10 Oct 2017 12:28:32 +0300
Message-ID: <1507627715-25487-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48120 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755987AbdJJJ2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 05:28:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset from Inbar contains changes to rings control
to the mlx4 Eth driver.

Patches 1 and 2 limit the number of rings to the number of CPUs.
Patch 3 removes a limitation in logic of default number of RX rings.

Series generated against net-next commit:
812b5ca7d376 Add a driver for Renesas uPD60620 and uPD60620A PHYs

Thanks,
Tariq.


Inbar Karmy (3):
  net/mlx4_en: Limit the number of TX rings
  net/mlx4_en: Limit the number of RX rings
  net/mlx4_en: Increase number of default RX rings

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 11 ++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  3 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 5 files changed, 14 insertions(+), 10 deletions(-)

-- 
1.8.3.1
