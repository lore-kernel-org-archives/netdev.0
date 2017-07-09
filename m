From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/7] Mellanox, mlx5 fixes 2017-07-09
Date: Sun,  9 Jul 2017 15:49:10 +0300
Message-ID: <20170709124917.12852-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36237 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752134AbdGIMuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 08:50:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series includes fixes to mlx5 driver:
  - Compilation warnings and issues introduced on v4.12
  - Add Makefile to each mlx5 subdir to allow individual file compilation
  - Initialize CEE's getpermhwaddr address buffer to 0xff

Please pull and let me know if there's any problem.

For -stable:
 ("net/mlx5e: Initialize CEE's getpermhwaddr address buffer to 0xff") Kernels >= 4.10

Thanks,
Saeed.

---

The following changes since commit 3d05035efaac1e9a4583b62cd70ecb8541399c0f:

  ptp: dte: Use LL suffix for 64-bit constants (2017-07-06 11:40:58 +0100)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-07-09

for you to fetch changes up to d968f0f2e4404152f37ed2384b4a2269dd2dae5a:

  net/mlx5e: Initialize CEE's getpermhwaddr address buffer to 0xff (2017-07-06 15:13:20 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-07-09

This series includes fixes to mlx5 driver:
 - Compilation warnings and issues introduced on v4.12
 - Initialize CEE's getpermhwaddr address buffer to 0xff

----------------------------------------------------------------
Huy Nguyen (1):
      net/mlx5e: Initialize CEE's getpermhwaddr address buffer to 0xff

Ilan Tayari (6):
      net/mlx5: Add missing include in lib/gid.c
      net/mlx5: IPSec, Fix 64-bit division on 32-bit builds
      net/mlx5: FPGA, make mlx5_fpga_device_brb static
      net/mlx5: FPGA, Fix datatype mismatch
      net/mlx5: Build wq.o even if MLX5_CORE_EN is not selected
      net/mlx5: Add Makefiles for subdirectories

 drivers/net/ethernet/mellanox/mlx5/core/Makefile              | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile        | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile     | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c | 4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c            | 2 ++
 drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile         | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/fpga/core.c           | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fpga/ipsec.c          | 4 ++--
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile        | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile          | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/lib/gid.c             | 1 +
 11 files changed, 16 insertions(+), 6 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/accel/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_accel/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fpga/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile
