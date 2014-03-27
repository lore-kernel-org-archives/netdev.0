From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/3] Implement vxlan ndo calls
Date: Thu, 27 Mar 2014 14:02:01 +0200
Message-ID: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55708 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751683AbaC0MCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This short series adds support for the vxlan ndo calls, the udp
port is programmed to the firmware using a new command we introduce
here which is called "config device".

Or.

Or Gerlitz (3):
  net/mlx4: USe one wrapper that returns -EPERM
  mlx4: Add support for CONFIG_DEV command
  net/mlx4: Implement vxlan ndo calls

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   26 +++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   86 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   40 +++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    3 +
 drivers/net/ethernet/mellanox/mlx4/port.c          |    5 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   10 ---
 include/linux/mlx4/cmd.h                           |    1 +
 include/linux/mlx4/device.h                        |    4 +-
 9 files changed, 147 insertions(+), 33 deletions(-)
