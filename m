From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/5] mlx4 misc fixes and improvements
Date: Mon, 12 Sep 2016 16:20:11 +0300
Message-ID: <1473686416-11779-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53414 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757742AbcILNUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 09:20:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains some bug fixes, a cleanup, and small improvements
from the team to the mlx4 Eth and core drivers.

Series generated against net-next commit:
02154927c115 "net: dsa: bcm_sf2: Get VLAN_PORT_MASK from b53_device"

Please push the following patch to -stable  >= 4.6 as well:
"net/mlx4_core: Fix to clean devlink resources"

Thanks,
Tariq.

Jack Morgenstein (1):
  net/mlx4_core: Fix deadlock when switching between polling and event
    fw commands

Kamal Heib (2):
  net/mlx4_en: Fix wrong indentation
  net/mlx4_core: Fix to clean devlink resources

Leon Romanovsky (1):
  net/mlx4_core: Use RCU to perform radix tree lookup for SRQ

Tariq Toukan (1):
  net/mlx4_en: Add branch prediction hints in RX data-path

 drivers/net/ethernet/mellanox/mlx4/cmd.c   | 23 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 28 +++++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/main.c  |  3 +++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h  |  2 ++
 drivers/net/ethernet/mellanox/mlx4/srq.c   | 14 +++++---------
 5 files changed, 42 insertions(+), 28 deletions(-)

-- 
1.8.3.1
