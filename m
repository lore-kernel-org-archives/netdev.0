From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 0/3] mlx5 driver changes related to PCI handling ***
Date: Mon, 28 Jul 2014 23:30:21 +0300
Message-ID: <1406579424-16213-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org, ogerlitz@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36129 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaG1Uag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 16:30:36 -0400
Received: by mail-wg0-f49.google.com with SMTP id k14so7865075wgh.20
        for <netdev@vger.kernel.org>; Mon, 28 Jul 2014 13:30:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The first of these patches is changing the pci device driver from mlx5_ib to
mlx5_core in a similar manner it is done in mlx4. This set the grounds for us
to introduce Ethernet driver for HW which uses mlx5.

The other two patches contain minor fixes.

Eli

Jack Morgenstein (3):
  mlx5: Move pci device from mlx5_ib to mlx5_core
  mlx5: minor fixes (mainly avoidance of hidden casts)
  mlx5: Adjust events to use unsigned long param instead of void *

 drivers/infiniband/hw/mlx5/cq.c                    |  48 ++--
 drivers/infiniband/hw/mlx5/mad.c                   |   6 +-
 drivers/infiniband/hw/mlx5/main.c                  | 292 +++++++--------------
 drivers/infiniband/hw/mlx5/mem.c                   |   2 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |  14 +-
 drivers/infiniband/hw/mlx5/mr.c                    |  48 ++--
 drivers/infiniband/hw/mlx5/qp.c                    |  88 +++----
 drivers/infiniband/hw/mlx5/srq.c                   |  26 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/mad.c      |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 292 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   2 +-
 include/linux/mlx5/device.h                        |   4 -
 include/linux/mlx5/driver.h                        |  27 +-
 17 files changed, 522 insertions(+), 339 deletions(-)

-- 
1.9.3
