From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 0/4] mlx5 update for 3.18
Date: Tue, 30 Sep 2014 16:02:11 +0300
Message-ID: <1412082135-30229-2-git-send-email-eli@mellanox.com>
References: <1412082135-30229-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:39561 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbaI3NCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 09:02:31 -0400
Received: by mail-wg0-f47.google.com with SMTP id x13so317494wgg.18
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 06:02:30 -0700 (PDT)
In-Reply-To: <1412082135-30229-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series integrates a new mechanism for populating and extracting field values 
used in the driver/firmware interaction around command mailboxes.

Eli.


Eli Cohen (4):
  net/mlx5_core: Update device capabilities handling
  net/mlx5_core: Use hardware registers description header file
  net/mlx5_core: use set/get macros in device caps
  net/mlx5_core: Identify resources by their type

 drivers/infiniband/hw/mlx5/cq.c                |    8 +-
 drivers/infiniband/hw/mlx5/mad.c               |    2 +-
 drivers/infiniband/hw/mlx5/main.c              |   83 +-
 drivers/infiniband/hw/mlx5/qp.c                |   72 +-
 drivers/infiniband/hw/mlx5/srq.c               |    6 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c  |   77 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |   14 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c   |   81 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c |  229 +-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c   |   60 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  |    4 +-
 include/linux/mlx5/device.h                    |  182 +-
 include/linux/mlx5/driver.h                    |  118 +-
 include/linux/mlx5/mlx5_ifc.h                  | 4464 ++++++++++++++++++++++++
 include/linux/mlx5/qp.h                        |    3 +-
 15 files changed, 4948 insertions(+), 455 deletions(-)
 create mode 100644 include/linux/mlx5/mlx5_ifc.h

-- 
2.1.1
