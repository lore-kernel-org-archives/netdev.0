From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] Mellanox mlx4 driver fixes
Date: Thu, 17 Dec 2015 15:35:36 +0200
Message-ID: <1450359338-32220-1-git-send-email-ogerlitz@mellanox.com>
References: <a>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36159 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752528AbbLQNgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 08:36:06 -0500
In-Reply-To: <a>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Two small fixes from Jenny for code flows that deal with time-stamping.


Or.

Eugenia Emantayev (2):
  net/mlx4_en: Remove dependency between timestamping capability and service_task
  net/mlx4_en: Fix HW timestamp init issue upon system startup

 drivers/net/ethernet/mellanox/mlx4/en_clock.c  |  7 +++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |  7 -------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 10 ++++++++--
 3 files changed, 15 insertions(+), 9 deletions(-)

-- 
2.3.7
