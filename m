From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/3] Mellanox, mlx5 fixes 2017-06-28
Date: Fri, 30 Jun 2017 10:12:26 +0300
Message-ID: <20170630071229.20357-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44936 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751565AbdF3HNi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 03:13:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains some fixes for the mlx5 core and netdev driver.

Please pull and let me know if there's any problem.

For -stable:
("net/mlx5e: Fix TX carrier errors report in get stats ndo") Kernels >= v4.7

("net/mlx5: Cancel delayed recovery work when unloading the driver") Kernels >= v4.10
* When applied to net-next this will introduce a contextual conflict, it
should be easy to resolve, (a spin_lock was changed to spin_lock_irqsave in net-next),
if you need any help with this please let me know.

("net/mlx5: Fix driver load error flow when firmware is stuck") Kernels >= v4.4*
* This patch fixes: 6c780a0267b8 ("net/mlx5: Wait for FW readiness before initializing command interface")
which was submitted two weeks ago and queued up for v4.4.

Sorry about the mess, but other than the above, this series doesn't introduce
any conflict with the current mlx5 IPSec offload series.

Thanks,
Saeed.

---

The following changes since commit d747a7a51b00984127a88113cdbbc26f91e9d815:

  tcp: reset sk_rx_dst in tcp_disconnect() (2017-06-25 12:23:07 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-06-28

for you to fetch changes up to 8ff93de7668bd81bc8efa819d1184ebd48fae72d:

  net/mlx5e: Fix TX carrier errors report in get stats ndo (2017-06-27 14:49:57 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-06-28

----------------------------------------------------------------
Gal Pressman (2):
      net/mlx5: Fix driver load error flow when firmware is stuck
      net/mlx5e: Fix TX carrier errors report in get stats ndo

Mohamad Haj Yahia (1):
      net/mlx5: Cancel delayed recovery work when unloading the driver

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  2 --
 drivers/net/ethernet/mellanox/mlx5/core/health.c  | 15 ++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  4 ++--
 include/linux/mlx5/driver.h                       |  1 +
 4 files changed, 17 insertions(+), 5 deletions(-)
