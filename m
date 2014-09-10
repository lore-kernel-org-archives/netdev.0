From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/4] mlx4 SRIOV fixes
Date: Wed, 10 Sep 2014 16:41:52 +0300
Message-ID: <1410356516-23594-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45886 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750925AbaIJNmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 09:42:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains few SRIOV related fixes from Matan, please apply to net.

Or.

Matan Barak (4):
  net/mlx4: Correctly configure single ported VFs from the host
  net/mlx4: Use the correct VSD mask in UPDATE_QP
  net/mlx4: Avoid dealing with MAC index in UPDATE_QP wrapper if not needed
  net/mlx4: Set vlan stripping policy by the right command

 drivers/infiniband/hw/mlx4/main.c                  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   21 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   12 +++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   38 ++++++++++++++-----
 include/linux/mlx4/device.h                        |    1 +
 include/linux/mlx4/qp.h                            |   12 +++++-
 6 files changed, 71 insertions(+), 15 deletions(-)
