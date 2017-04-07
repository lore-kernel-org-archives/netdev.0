From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 0/7] Mellanox mlx5 updates 2017-04-16
Date: Fri,  7 Apr 2017 21:26:49 +0300
Message-ID: <20170407182656.6734-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47242 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756021AbdDGS1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:27:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following changes provide some small features and updates to the mlx5
driver.

For more information please see below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit bd414860440eebc8a7eb54be94c97e6ed09bb402:

  Merge tag 'batadv-next-for-davem-20170406' of git://git.open-mesh.org/linux-merge (2017-04-06 14:37:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-04-16

for you to fetch changes up to 457fcd8a11f7f7f2483b2366d8a98f269c085302:

  net/mlx5e: Set default RX moderation parameters on driver load (2017-04-07 01:21:28 +0300)

----------------------------------------------------------------
mlx5-updates-2017-04-16

This patchset provides some updates for the mlx5 drivers.

>From Majd,
1st patch, Adds ConnectX-6 and ConnectX-6 VF PCI IDs support.

>From Guy,
2nd patch, Adds RXFCS scatter support.
3rd patch, Small cleanup to make a function static.

>From Eran,
4th patch, Adds 4 zeros padding to ethtool FW version.
6th patch, Trevial code reuse cleanup

>From Inbar,
5th patch, Show board id in ethtool driver information

>From Saeed,
7th patch, Set default RX moderation parameters on driver load
as a small fix for the latest fail-safe config feature.

Thanks,
Saeed.

----------------------------------------------------------------
Eran Ben Elisha (2):
      net/mlx5e: Change FW sub_minor display to 4 zeros padding
      net/mlx5e: Reuse alloc cq code for all CQs allocation

Guy Ergas (2):
      net/mlx5e: Add support for RXFCS feature flag
      net/mlx5e: Make mlx5e_modify_rqs_vsd a static function

Inbar Karmy (1):
      net/mlx5e: Show board id in ethtool driver information

Majd Dibbiny (1):
      net/mlx5: Update the list of the PCI supported devices

Saeed Mahameed (1):
      net/mlx5e: Set default RX moderation parameters on driver load

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   3 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 140 +++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   6 +-
 include/linux/mlx5/mlx5_ifc.h                      |   1 +
 5 files changed, 108 insertions(+), 47 deletions(-)
