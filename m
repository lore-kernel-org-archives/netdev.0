From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] Setup mlx4 user space Ethernet QPs to properly handle VXLAN
Date: Wed, 27 Aug 2014 16:44:37 +0300
Message-ID: <1409147079-18826-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50042 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933583AbaH0Nou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 09:44:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This short series fixes the mlx4 driver setting of user space Ethernet QPs
(e.g those opened by DPDK applications) such that they will properly handle
VXLAN traffic/offloads

Or.

Or Gerlitz (2):
  net/mlx4: Move the tunnel steering helper function to mlx4_core
  mlx4: Set user-space raw Ethernet QPs to properly handle VXLAN traffic

 drivers/infiniband/hw/mlx4/main.c              |   30 +++++++++++++++++++
 drivers/infiniband/hw/mlx4/qp.c                |    8 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   31 +------------------
 drivers/net/ethernet/mellanox/mlx4/mcg.c       |   38 ++++++++++++++++++++++++
 include/linux/mlx4/device.h                    |    3 ++
 5 files changed, 80 insertions(+), 30 deletions(-)
