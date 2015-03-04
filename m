From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/3] Add QCN support to the DCB NL layer
Date: Wed,  4 Mar 2015 14:51:05 +0200
Message-ID: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53496 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756050AbbCDMvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 07:51:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, John, all

This series from Shani Michaeli adds support for the IEEE QCN attribute 
to the kernel DCB NL stack, and implementation in the mlx4 driver which
programs the firmware according to the admin directives.

Or.

Shani Michaeli (3):
  net/dcb: Add IEEE QCN attribute
  net/mlx4_core: Add basic elements for QCN
  net/mlx4_en: Add QCN parameters and statistics handling

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |    9 +
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |  218 ++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   13 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    1 +
 include/linux/mlx4/cmd.h                       |   13 ++
 include/linux/mlx4/device.h                    |    3 +-
 include/net/dcbnl.h                            |    3 +
 include/uapi/linux/dcbnl.h                     |   66 +++++++
 net/dcb/dcbnl.c                                |   41 ++++-
 9 files changed, 361 insertions(+), 6 deletions(-)
