From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/3] Fix mlx4 static checker warnings
Date: Mon,  9 Oct 2017 16:59:47 +0300
Message-ID: <1507557590-17747-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33668 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754826AbdJIOAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 10:00:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains fixes for static checker warnings
in the mlx4 Core and Eth drivers.

Patch 1 fixes an actual bug discovered by the checker.
Patches 2 and 3 fix the warnings without functional changes.

Series generated against net-next commit:
c49c777f9c87 qed: Delete redundant check on dcb_app priority

Thanks,
Tariq.


Tariq Toukan (3):
  net/mlx4: Fix endianness issue in qp context params
  net/mlx4_core: Fix cast warning in fw.c
  net/mlx4_en: Use __force to fix a sparse warning in TX datapath

 drivers/net/ethernet/mellanox/mlx4/en_resources.c     | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c            | 2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c               | 6 +++---
 drivers/net/ethernet/mellanox/mlx4/qp.c               | 2 +-
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

-- 
1.8.3.1
