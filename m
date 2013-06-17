From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] Low latency Socket support
Date: Mon, 17 Jun 2013 13:58:21 +0300
Message-ID: <1371466703-3370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, eliezer.tamir@linux.intel.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46150 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932396Ab3FQK6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 06:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please pull those 2 patches, which add support in Low Latency Socket (LLS) to
mlx4_en.

Thanks,
Amir

Amir Vadai (2):
  net/mlx4_en: Add Low Latency Socket (LLS) support
  net/mlx4_en: Low Latency recv statistics

 drivers/net/ethernet/mellanox/mlx4/en_cq.c      |   2 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  20 +++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  49 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   8 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 133 ++++++++++++++++++++++++
 5 files changed, 209 insertions(+), 3 deletions(-)

-- 
1.8.3.251.g1462b67
