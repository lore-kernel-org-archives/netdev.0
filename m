From: Amir Vadai <amirv@dev.mellanox.co.il>
Subject: [PATCH 0/3] mlx4_en: loopback support + RSS TCP improve + bug fix
Date: Tue, 15 Nov 2011 11:14:03 +0200
Message-ID: <1321348446-29605-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Oren Duer <oren@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58272 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab1KOJOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 04:14:32 -0500
Received: by bke11 with SMTP id 11so6906612bke.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 01:14:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.co.il>

Amir Vadai (3):
  net/mlx4_en: allow setting number of rx rings for RSS/TCP
  net/mlx4_en: adding loopback support
  net/mlx4_en: bug fix for the case of vlan id 0 and UP 0

 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    7 ++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    9 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    6 ++++--
 include/linux/mlx4/qp.h                        |    1 +
 5 files changed, 18 insertions(+), 7 deletions(-)

-- 
1.7.5.4
