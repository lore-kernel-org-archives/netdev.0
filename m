From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 00/11] Mellanox, mlx5 fixes 2017-08-30
Date: Thu, 31 Aug 2017 01:20:59 +0300
Message-ID: <20170830222110.15737-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53214 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750814AbdH3WVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:21:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some misc fixes to the mlx5 driver.

Please pull and let me know if there's any problem.

For -stable:   

Kernels >= 4.12
	net/mlx5e: Fix CQ moderation mode not set properly
	net/mlx5e: Don't override user RSS upon set channels

Kernels >= 4.11
	net/mlx5e: Properly resolve TC offloaded ipv6 vxlan tunnel source address 

Kernels >= 4.10
	net/mlx5e: Fix DCB_CAP_ATTR_DCBX capability for DCBNL getcap
	net/mlx5e: Check for qos capability in dcbnl_initialize

Kernels >= 4.9
	net/mlx5e: Fix dangling page pointer on DMA mapping error

Kernels >= 4.8
	net/mlx5e: Fix inline header size for small packets
	net/mlx5: E-Switch, Unload the representors in the correct order
    	net/mlx5: Fix arm SRQ command for ISSI version 0


Thanks,
Saeed.

---

The following changes since commit 183db481279437590f75a8a0479d512e5dd597de:

  drivers: net: xgene: Correct probe sequence handling (2017-08-29 16:13:08 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-08-30

for you to fetch changes up to 1213ad28f9595a08e3877248bbba1a25c40225d6:

  net/mlx5e: Fix CQ moderation mode not set properly (2017-08-30 21:20:43 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-08-30

----------------------------------------------------------------
Eran Ben Elisha (1):
      net/mlx5e: Fix dangling page pointer on DMA mapping error

Huy Nguyen (4):
      net/mlx5e: Check for qos capability in dcbnl_initialize
      net/mlx5e: Fix DCB_CAP_ATTR_DCBX capability for DCBNL getcap.
      net/mlx5: Skip mlx5_unload_one if mlx5_load_one fails
      net/mlx5: Remove the flag MLX5_INTERFACE_STATE_SHUTDOWN

Inbar Karmy (1):
      net/mlx5e: Don't override user RSS upon set channels

Moshe Shemesh (1):
      net/mlx5e: Fix inline header size for small packets

Noa Osherovich (1):
      net/mlx5: Fix arm SRQ command for ISSI version 0

Paul Blakey (1):
      net/mlx5e: Properly resolve TC offloaded ipv6 vxlan tunnel source address

Shahar Klein (1):
      net/mlx5: E-Switch, Unload the representors in the correct order

Tal Gilboa (1):
      net/mlx5e: Fix CQ moderation mode not set properly

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 24 ++++++++++++++--------
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  6 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  8 +++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 17 ++++++++-------
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  6 +-----
 drivers/net/ethernet/mellanox/mlx5/core/srq.c      | 12 +++++------
 include/linux/mlx5/driver.h                        |  4 +---
 11 files changed, 44 insertions(+), 39 deletions(-)
