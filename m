From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/4] mlx4 driver fixes, July 22nd 2015
Date: Wed, 22 Jul 2015 16:53:45 +0300
Message-ID: <1437573229-13127-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54938 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S934195AbbGVNyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2015 09:54:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Just few mlx4 fixes.. the fix related to propagating port state
changes to VF should go to -stable of >= 3.11, all the rest just
to 4.2-rc

Or.

Ido Shamay (1):
  net/mlx4_en: Remove BUG_ON assert when checking if ring is full

Jack Morgenstein (2):
  net/mlx4_core: Fix wrong index in propagating port change event to VFs
  net/mlx4_core: Relieve cpu load average on the port sending flow

Or Gerlitz (1):
  net/mlx4_core: Use sink counter for the VF default as fallback

 drivers/net/ethernet/mellanox/mlx4/cmd.c   | 17 +++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |  1 -
 drivers/net/ethernet/mellanox/mlx4/eq.c    |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/main.c  |  5 +++++
 4 files changed, 22 insertions(+), 5 deletions(-)

-- 
2.3.7
