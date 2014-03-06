From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 0/2] net/mlx4_core: SR-IOV related fixes
Date: Thu,  6 Mar 2014 18:28:15 +0200
Message-ID: <1394123297-7878-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>, Narendra_K@Dell.com,
	Sreekanth_Reddy@Dell.com, Amir Vadai <amirv@mellanox.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43405 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751469AbaCFQ21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 11:28:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This small patchset fixes two issues in VF/PF initialization and loading.
First patch fixes a typo that caused a memory access error during VF
initialization.
Second patch prevent the PF probe function from being blocked for many seconds
while probing VF's

Patches were tested and applied on commit 1b07da5: "hyperv: Move state setting
for link query"

Thanks,
Amir

Amir Vadai (2):
  net/mlx4_core: Fix memory access error in mlx4_QUERY_DEV_CAP_wrapper()
  net/mlx4_core: mlx4_init_slave() shouldn't access comm channel before
    PF is ready

 drivers/net/ethernet/mellanox/mlx4/fw.c   |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/main.c | 11 +++++++++++
 2 files changed, 14 insertions(+), 3 deletions(-)

-- 
1.8.3.4
