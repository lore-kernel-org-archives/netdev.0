From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 0/2] net/mlx4_core: Deprecate module parameter use_prio
Date: Thu, 22 May 2014 15:55:38 +0300
Message-ID: <1400763340-15028-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43328 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753638AbaEVMzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 08:55:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This small patchset deprecates the mlx4_core module paramater 'use_prio', as
suggested by Carol Soto from IBM in [1].
Also, replaced some calls to the prefered pr_warn/info/devel macro's.

Patchset was applied and tested on commit b6052af: "Merge tag
'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge"

[1] - http://marc.info/?l=linux-netdev&m=139871350103432&w=2

Changes from V0:
- Patch 1/2: Deprecate use_prio module parameter
  - Commit message was confusing and not accurate, rewrote it

Thanks,
Amir

Amir Vadai (2):
  net/mlx4_core: Deprecate use_prio module parameter
  net/mlx4_core: Replace pr_warning() with pr_warn()

 drivers/net/ethernet/mellanox/mlx4/cmd.c            |  6 +++---
 drivers/net/ethernet/mellanox/mlx4/main.c           | 21 +++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/mr.c             |  6 ++----
 .../net/ethernet/mellanox/mlx4/resource_tracker.c   | 10 +++++-----
 include/linux/mlx4/device.h                         |  1 -
 5 files changed, 21 insertions(+), 23 deletions(-)

-- 
1.8.3.4
