From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 0/4] net/mlx4_en: fix stats
Date: Wed, 25 May 2016 09:50:35 -0700
Message-ID: <1464195039-5098-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35406 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341AbcEYQup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 12:50:45 -0400
Received: by mail-pf0-f180.google.com with SMTP id g64so20345413pfb.2
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 09:50:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4 has various bugs in its ndo_get_stats() and related functions.
This patch series address the obvious issues.
Remaining ones will be discussed later.

Eric Dumazet (4):
  net/mlx4_en: fix tx_dropped bug
  net/mlx4_en: clear some TX ring stats in mlx4_en_clear_stats()
  net/mlx4_en: get rid of ret_stats
  net/mlx4_en: get rid of private net_device_stats

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 17 +++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_port.c    | 18 ++++++------------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  3 +--
 5 files changed, 23 insertions(+), 25 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
