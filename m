From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 0/4] mlx5 update for 3.18
Date: Tue, 30 Sep 2014 16:02:10 +0300
Message-ID: <1412082135-30229-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:50839 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaI3NC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 09:02:28 -0400
Received: by mail-we0-f181.google.com with SMTP id u57so3461936wes.12
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 06:02:27 -0700 (PDT)
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
