From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/4] mlx4 misc fixes
Date: Wed, 22 Feb 2017 14:33:23 +0200
Message-ID: <1487766807-13929-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Dexuan Cui <decui@microsoft.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54825 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754324AbdBVMeK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 07:34:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains misc bug fixes from the team
to the mlx4 Core and Eth drivers.

Series generated against net commit:
00ea1ceebe0d ipv6: release dst on error in ip6_dst_lookup_tail

Thanks,
Tariq.

Eugenia Emantayev (1):
  net/mlx4: Spoofcheck and zero MAC can't coexist

Jack Morgenstein (1):
  net/mlx4_core: Use cq quota in SRIOV when creating completion EQs

Majd Dibbiny (1):
  net/mlx4_core: Fix VF overwrite of module param which disables DMFS on
    new probed PFs

Or Gerlitz (1):
  net/mlx4: Change ENOTSUPP to EOPNOTSUPP

 drivers/net/ethernet/mellanox/mlx4/cmd.c           | 22 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c     |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  6 +-----
 drivers/net/ethernet/mellanox/mlx4/eq.c            |  5 ++---
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  2 +-
 drivers/net/ethernet/mellanox/mlx4/intf.c          |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          | 11 +++++------
 drivers/net/ethernet/mellanox/mlx4/mr.c            |  2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |  2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  2 +-
 include/linux/mlx4/cmd.h                           |  2 +-
 include/linux/mlx4/driver.h                        | 10 ++++++++++
 12 files changed, 45 insertions(+), 23 deletions(-)

-- 
1.8.3.1
