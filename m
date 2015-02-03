From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/7] Mellanox drivers updates Feb-03-2015
Date: Tue,  3 Feb 2015 17:57:14 +0200
Message-ID: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40255 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S965089AbbBCP6C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces some small bug fixes and code cleanups in mlx4_core,
mlx4_en and mlx5_core.
I am sending it in parallel to the patchset sent by Or Gerlitz today [1] because
this is the end of the time frame for 3.20. I also checked that there are no
conflicts between those two patchsets (Or's patchset is focused on the bonding
area while this on Mellanox drivers).

The patchset was applied on top of commit 7d37d0c ('net: sctp: Deletion of an
unnecessary check before the function call "kfree"')

[1] - [PATCH 00/10] Add HA and LAG support to mlx4 RoCE and SRIOV services
      http://marc.info/?l=linux-netdev&m=142297582610254&w=2

Thanks,
Amir

Ido Shamay (3):
  net/mlx4_en: Print page allocator information
  net/mlx4_en: Adjust RX frag strides to frag sizes
  net/mlx4_en: Notify TX Vlan offload change

Maor Gottlieb (2):
  net/mlx4_core: Fix mpt_entry initialization in
    mlx4_mr_rereg_mem_write()
  net/mlx4: mlx4_config_dev_retrieval() - Initialize struct config_dev
    before using

Or Gerlitz (2):
  net/mlx4_core: Fix misleading debug print on CQE stride support
  net/mlx5_core: Move to use hex PCI device IDs

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c        |  4 ++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c            |  9 +++++++--
 drivers/net/ethernet/mellanox/mlx4/fw.c               |  2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c             |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/mr.c               | 13 +++++--------
 drivers/net/ethernet/mellanox/mlx4/resource_tracker.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c        | 12 ++++++------
 7 files changed, 26 insertions(+), 19 deletions(-)

-- 
1.9.3
