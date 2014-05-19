From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] net/mlx4_core: Deprecate module parameter use_prio
Date: Mon, 19 May 2014 11:37:40 +0300
Message-ID: <1400488662-5657-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36330 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753162AbaESIiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 04:38:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This small patchset deprecates the mlx4_core module paramater 'use_prio', as
suggested by Carol Soto from IBM in [1].
Also, replaced some calls to the prefered pr_warn/info/devel macro's.

Patchset was applied and tested on commit b6052af: "Merge tag
'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge"

[1] - http://marc.info/?l=linux-netdev&m=139871350103432&w=2

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
