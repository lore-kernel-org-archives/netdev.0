From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/4] Batch of mlx4 fixes for 3.15
Date: Thu,  1 May 2014 15:51:52 +0300
Message-ID: <1398948716-6765-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, matanb@mellanox.com, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60424 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753611AbaEANRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 09:17:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series contains fixes for 3.15-rc, mostly around SRIOV. The patches by Jack, 
Matan and myself 
fix few issues related to mlx4 SRIOV support for RoCE and single port VFs, and the
patch from Eyal elimninates checking PCI caps for VFs which is misleading.

Patches done against the net tree, commit 014f1b2 "net: bonding: Fix format string 
mismatch in bond_sysfs.c"

We'd be happy to get Eyal's patch queued in your -stable list for 3.14.y

Or.

Eyal Perry (1):
  net/mlx4_core: Don't issue PCIe speed/width checks for VFs

Jack Morgenstein (1):
  net/mlx4_core: Adjust port number in qp_attach wrapper when detaching

Matan Barak (1):
  net/mlx4_core: Fix slave id computation for single port VF

Or Gerlitz (1):
  net/mlx4_core: Load the Eth driver first

 drivers/net/ethernet/mellanox/mlx4/main.c          |    7 ++--
 drivers/net/ethernet/mellanox/mlx4/port.c          |   35 +++++++++++--------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   23 +++++++++++++
 3 files changed, 47 insertions(+), 18 deletions(-)
