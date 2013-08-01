From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4_core fixes
Date: Thu,  1 Aug 2013 19:54:59 +0300
Message-ID: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:54540 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755792Ab3HAQy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 12:54:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Patch #1 complements commit ef96f7d46ad "net/mlx4_en: Handle unassigned VF MAC
address correctly" which took care of the VM side of things. It follows the
approach taken by the ixgbevf (e1941a7 "ixgbevf: Adjust to handle unassigned
MAC address from PF") and bnx2x (e09b74d01 "bnx2x: Zero VFs starting MACs")
drivers too, so users will experience unified approach across vendors.

Would be happy to see both patches land in -stable for 3.10.y - do you 
want to handle that through the peridioc batches you send to Greg?

The patches were done against the net tree, commit e44892c1b "igb: 
fix vlan filtering in promisc mode when not in VT mode"

Or.

Jack Morgenstein (1):
  net/mlx4_core: VFs must ignore the enable_64b_cqe_eqe module param

Or Gerlitz (1):
  net/mlx4_core: Don't give VFs MAC addresses which are derived from the PF MAC

 drivers/net/ethernet/mellanox/mlx4/fw.c   |   11 +----------
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 2 files changed, 2 insertions(+), 11 deletions(-)
