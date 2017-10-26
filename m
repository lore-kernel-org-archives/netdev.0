From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/4] Mellanox, mlx5 fixes 2017-10-26
Date: Thu, 26 Oct 2017 00:59:33 -0700
Message-ID: <20171026075937.26477-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48334 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751610AbdJZH7p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 03:59:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The series includes some misc fixes for mlx5 core and etherent driver.
Please pull and let me know if there's any problem.

For -Stable:
net/mlx5e: Properly deal with encap flows add/del under neigh update (kernels >= 4.12)
net/mlx5: Fix health work queue spin lock to IRQ safe  (kernels >= 4.13)

Thanks,
Saeed.

---

The following changes since commit 5c25f65fd1e42685f7ccd80e0621829c105785d9:

  tun: allow positive return values on dev_get_valid_name() call (2017-10-26 10:10:03 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-10-26

for you to fetch changes up to be0f161ef141e4df368aa3f417a1c2ab9c362e75:

  net/mlx5e: DCBNL, Implement tc with ets type and zero bandwidth (2017-10-26 00:47:27 -0700)

----------------------------------------------------------------
mlx5-fixes-2017-10-26

Misc fixes for mlx5 core and ethernet driver

----------------------------------------------------------------
Huy Nguyen (2):
      net/mlx5: Delay events till mlx5 interface's add complete for pci resume
      net/mlx5e: DCBNL, Implement tc with ets type and zero bandwidth

Moshe Shemesh (1):
      net/mlx5: Fix health work queue spin lock to IRQ safe

Or Gerlitz (1):
      net/mlx5e: Properly deal with encap flows add/del under neigh update

 drivers/net/ethernet/mellanox/mlx5/core/dev.c      |  70 +++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 113 +++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  89 +++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  21 ++++
 include/linux/mlx5/port.h                          |   2 +
 6 files changed, 204 insertions(+), 96 deletions(-)
