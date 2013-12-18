From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/2] net/mlx4: Add support for TCP/IP offloads of vxlan tunneling
Date: Wed, 18 Dec 2013 16:05:26 +0200
Message-ID: <1387375528-2337-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, yanb@mellanox.com,
	ast@plumgrid.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38430 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754021Ab3LROFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 09:05:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

These two patches add mlx4 support for TCP/IP offloads under vxlan tunneling

The patches are againt net-next commit 7ed2a0d "Merge branch 'for-davem' 
of git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next" plus the in-progress 
mlx4 series http://marc.info/?l=linux-netdev&m=138726378426919&w=2 -- the two 
patch series pretty much touch different areas and practically can be applied in any order.

Or.

Or Gerlitz (2):
  net/mlx4_core: Add basic support for TCP/IP offloads under tunneling
  net/mlx4_en: Add netdev support for TCP/IP offloads of vxlan tunneling

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   95 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    6 ++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   15 +++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   14 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.c           |   19 ++++-
 drivers/net/ethernet/mellanox/mlx4/main.c         |   14 +++
 drivers/net/ethernet/mellanox/mlx4/mcg.c          |   14 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |    3 +-
 drivers/net/ethernet/mellanox/mlx4/port.c         |   41 +++++++++
 include/linux/mlx4/cmd.h                          |    1 +
 include/linux/mlx4/cq.h                           |    5 +
 include/linux/mlx4/device.h                       |   37 ++++++++-
 include/linux/mlx4/qp.h                           |    6 ++
 13 files changed, 263 insertions(+), 7 deletions(-)
