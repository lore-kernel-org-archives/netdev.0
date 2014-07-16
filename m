From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/5] Mellanox driver update Jul-16-2014
Date: Wed, 16 Jul 2014 11:57:46 +0300
Message-ID: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35177 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759712AbaGPI6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 04:58:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset contains some bug fixes related to MCG table management (flow
steering) in Mellanox NIC.

Fixes were applied and tested over commit 0854a7f ("Merge branch
'amd811e-cleanups'").

Thanks,
Amir

Alexander Guller (1):
  net/mlx4_core: Make sure the max number of QPs per MCG isn't exceeded

Dotan Barak (1):
  net/mlx4_core: Make sure that negative array index isn't used

Eugenia Emantayev (1):
  net/mlx4_core: In SR-IOV mode host should add promisc QP to default
    entry only

Saeed Mahameed (1):
  net/mlx4_core: Remove MCG in case it is attached to promiscuous QPs
    only

Yevgeny Petrilin (1):
  net/mlx4_core: Fix leakage of SW multicast entries

 drivers/net/ethernet/mellanox/mlx4/mcg.c | 279 +++++++++++++++++++++----------
 1 file changed, 188 insertions(+), 91 deletions(-)

-- 
1.8.3.4
