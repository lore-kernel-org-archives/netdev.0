From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/3] mlx4_en XDP TX improvements
Date: Wed, 11 Oct 2017 13:17:24 +0300
Message-ID: <1507717047-29255-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        kernel-team@fb.com, Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53164 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752385AbdJKKRs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 06:17:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains performance improvements
to the XDP_TX use case in the mlx4 Eth driver.

Patch 1 is a simple change in a function parameter type.
Patch 2 replaces a call to a generic function with the
  relevant parts inlined.
Patch 3 moves the write of descriptors' constant values
  from data path to control path.

Series generated against net-next commit:
833e0e2f24fd net: dst: move cpu inside ifdef to avoid compilation warning

Thanks,
Tariq.


Tariq Toukan (3):
  net/mlx4_en: Replace netdev parameter with priv in XDP xmit function
  net/mlx4_en: Obsolete call to generic write_desc in XDP xmit flow
  net/mlx4_en: XDP_TX, assign constant values of TX descs on ring
    creaion

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  1 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 46 +++++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  4 ++-
 4 files changed, 36 insertions(+), 17 deletions(-)

-- 
1.8.3.1
