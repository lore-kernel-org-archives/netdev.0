From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/3] mlx4 misc fixes
Date: Tue,  9 May 2017 14:45:21 +0300
Message-ID: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49005 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752190AbdEILpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 07:45:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains misc bug fixes from the team
to the mlx4 Core and Eth drivers.

Series generated against net commit:
32f1bc0f3d26 Revert "ipv4: restore rt->fi for reference counting"

Thanks,
Tariq.

Jack Morgenstein (1):
  net/mlx4_core: Reduce harmless SRIOV error message to debug level

Kamal Heib (1):
  net/mlx4_en: Change the error print to debug print

Talat Batheesh (1):
  net/mlx4_en: Avoid adding steering rules with invalid ring

 drivers/net/ethernet/mellanox/mlx4/cmd.c              | 14 +++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c       |  5 +++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c            |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 4 files changed, 19 insertions(+), 5 deletions(-)

-- 
1.8.3.1
