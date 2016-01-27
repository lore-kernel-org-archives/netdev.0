From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx5 driver fixes for 4.5-rc1
Date: Wed, 27 Jan 2016 17:02:23 +0200
Message-ID: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49138 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933045AbcA0PC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 10:02:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Amir fixed a case where we could attempt to set destination for 
a non-forwarding (e.g drop) steering rule. Saeed fixed the case 
where VFs probed to the host shared the PF ndo_set_vf_yyy NDOs
which is wrong.

Or.

Amir Vadai (1):
  net/mlx5_core: Set flow steering dest only for forward rules

Saeed Mahameed (1):
  net/mlx5e: Use a private copy of netdev ops

 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 52 ++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  | 33 +++++++-------
 3 files changed, 48 insertions(+), 39 deletions(-)

-- 
2.3.7
