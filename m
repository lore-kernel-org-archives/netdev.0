From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/3] Add max rate TXQ attribute
Date: Sun, 15 Mar 2015 15:03:13 +0200
Message-ID: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51855 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751856AbbCONDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2015 09:03:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ability to set a max-rate limitation for TX queues.
The attribute name is maxrate and the units are Mbs, to make
it similar to the existing max-rate limitation knobs (ETS and 
SRIOV ndo calls).

Or.

changes from V1:
  - addressed feedback from Dave 

changes from V0:
  - addressed feedback from Sergei



John Fastabend (1):
  net: Add max rate tx queue attribute

Or Gerlitz (2):
  net/mlx4_core: Add basic support for QP max-rate limiting
  net/mlx4_en: Add tx queue maxrate support

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   29 +++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   33 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 ++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    6 ++-
 include/linux/mlx4/device.h                        |   17 +++++
 include/linux/mlx4/qp.h                            |   14 +++-
 include/linux/netdevice.h                          |    9 +++
 net/core/net-sysfs.c                               |   67 ++++++++++++++++----
 10 files changed, 165 insertions(+), 18 deletions(-)
