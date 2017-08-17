From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/15] Mellanox, mlx5 updates 2017-08-17
Date: Thu, 17 Aug 2017 16:29:48 +0300
Message-ID: <20170817133003.16900-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47099 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751107AbdHQNaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 09:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Tthe following changes provide updates for mlx5 ethernet and IPoIB
netdevice driver.

For more details please see tag log message below.
Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit f03b488b2fb1af20a290509b1ed25db08391b4e7:

  Merge branch 'vmbus-sendpacket-cleanups' (2017-08-16 16:27:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-08-17

for you to fetch changes up to 9a1ceef8a42cb90406b6adc620e63e9a11e04dbb:

  net/mlx5e: Use size_t to store byte offset in statistics descriptors (2017-08-17 15:57:15 +0300)

----------------------------------------------------------------
mlx5-updates-2017-08-17

Some updates for mlx5 ethernet and IPoIB device driver.

Eran added the support for manage physical link state from netdevice upon
interface open/close requests.

Feras fixed the driver name showed in ethtool for IPoIB interfaces.
Shalom Added the support for IPoIB netdevice ethtool get link settings.

Gal and Eran exposed new diagnostic counters for outbound PCIe stalls and overflow
and RX buffer fullness statistics.

Code cleanups from Or Gerlitz.
Variable types cleanup from Gal.

Thanks,
Saeed.

----------------------------------------------------------------
Eran Ben Elisha (2):
      net/mlx5e: Send PAOS command on interface up/down
      net/mlx5e: Add outbound PCI buffer overflow counter

Feras Daoud (1):
      net/mlx5e: IPoIB, Fix driver name retrieved by ethtool

Gal Pressman (6):
      net/mlx5: Add PCIe outbound stalls counters infrastructure
      net/mlx5e: Add PCIe outbound stalls counters
      net/mlx5: Add RX buffer fullness counters infrastructure
      net/mlx5e: Add RX buffer fullness counters
      net/mlx5e: Use kernel types instead of uint*_t in ethtool callbacks
      net/mlx5e: Use size_t to store byte offset in statistics descriptors

Or Gerlitz (5):
      net/mlx5: Avoid blank lines after/before open/close brace
      net/mlx5: Add a blank line after declarations
      net/mlx5e: Properly indent within conditional statements
      net/mlx5e: Avoid using multiple blank lines
      net/mlx5e: Place constants on the right side of comparisons

Shalom Lagziel (1):
      net/mlx5e: IPoIB, Add support for get_link_ksettings in ethtool

 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   1 -
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  55 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  13 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  20 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  46 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   1 +
 .../ethernet/mellanox/mlx5/core/ipoib/ethtool.c    | 135 ++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   1 -
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |   1 -
 include/linux/mlx5/mlx5_ifc.h                      |  34 +++++-
 12 files changed, 261 insertions(+), 51 deletions(-)
