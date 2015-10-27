From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] Mellanox mlx4 driver fixes for 4.3-rc7
Date: Tue, 27 Oct 2015 17:36:18 +0200
Message-ID: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45129 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751957AbbJ0Pgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 11:36:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Jack's fix is for a regression introduced in 4.3-rc1

Carol's fix addresses an issue which exists for while and 
turns to beat us hard on PPC, please queue for -stable. 

Or.

Carol L Soto (1):
  net/mlx4: Copy/set only sizeof struct mlx4_eqe bytes

Jack Morgenstein (1):
  net/mlx4_en: Explicitly set no vlan tags in WQE ctrl segment when no
    vlan is present

 drivers/net/ethernet/mellanox/mlx4/cmd.c   | 2 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c | 2 ++
 drivers/net/ethernet/mellanox/mlx4/eq.c    | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

-- 
2.3.7
