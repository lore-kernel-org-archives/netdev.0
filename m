From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 0/8] mlx4 misc improvements
Date: Sun, 29 Jan 2017 18:56:12 +0200
Message-ID: <1485708980-23468-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40185 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751838AbdA2Q5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 11:57:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains several improvements and cleanups
from the team to the mlx4 Eth and core drivers.

Series generated against net-next commit:
4e8f2fc1a55d Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net

Thanks,
Tariq.

v3:
* Patch 6/9: forgot to actually update the commit message in v2, now it is.

v2:
* Patch 1/9: used EOPNOTSUPP and not ENOTSUPP.
* Patch 3/9: dropped, to be submitted separately in the future.
* Patch 6/9: updated commit message.

Alaa Hleihel (1):
  net/mlx4_core: Get num_tc using netdev_get_num_tc

Ariel Levkovich (1):
  net/mlx4_en: Adding support of turning off link autonegotiation via
    ethtool

Matan Barak (1):
  net/mlx4_core: Add resource alloc/dealloc debugging

Shaker Daibes (3):
  net/mlx4_en: Pass user MTU value to Firmware at set port command
  net/mlx4_en: Check the enabling mtu flag in SET_PORT wrapper flow
  net/mlx4_en: Check the enabling pptx/pprx flags in SET_PORT wrapper
    flow

Tariq Toukan (1):
  net/mlx4: Replace ENOSYS with better fitting error codes

Yishai Hadas (1):
  net/mlx4_core: Device revision support

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  28 +++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   8 +
 drivers/net/ethernet/mellanox/mlx4/en_port.h       |   1 -
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   6 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |   6 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |  11 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          | 170 ++++++++++++++++-----
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  51 ++++++-
 include/linux/mlx4/device.h                        |   8 +-
 10 files changed, 228 insertions(+), 63 deletions(-)

-- 
1.8.3.1
