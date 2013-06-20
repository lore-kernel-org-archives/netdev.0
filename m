From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 00/11] Mellanox driver updates 2013-06-20
Date: Thu, 20 Jun 2013 22:40:11 +0300
Message-ID: <1371757222-21412-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:48207 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030249Ab3FTTkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 15:40:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Sorry for sending you the patchset twice - I didn't add netdev to the CC's
before.

This patchset contains some small fixes to mlx4_core and mlx4_en.
Patchset was applied and tested on commit: "fedaf4f ndisc:
Convert use of typedef ctl_table to struct ctl_table"

Thanks,
Amir

Dotan Barak (4):
  net/mlx4_en: Fix resource leak in error flow
  net/mlx4_en: Remove an unnecessary test
  net/mlx4_core: Replace sscanf() with kstrtoint()
  net/mlx4_core: Add warning in case of command timeouts

Eugenia Emantayev (3):
  net/mlx4_en: Move register_netdev() to the end of initialization
    function
  net/mlx4_en: Change log level from error to debug for vlan related
    messages
  net/mlx4_en: Fix a race between napi poll function and RX ring cleanup

Jack Morgenstein (2):
  net/mlx4_en: Do not query stats when device port is down
  net/mlx4_core: Fail device init if num_vfs is negative

Yevgeny Petrilin (2):
  net/mlx4_en: Suppress page allocation failure warnings
  net/mlx4_en: Add prints when TX timeout occurs

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |  6 +++++
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |  3 ---
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 35 ++++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  4 +--
 drivers/net/ethernet/mellanox/mlx4/main.c      | 11 +++++---
 6 files changed, 41 insertions(+), 20 deletions(-)

-- 
1.8.3.251.g1462b67
