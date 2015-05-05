From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4 fixes for 4.1-rc2
Date: Tue,  5 May 2015 17:07:10 +0300
Message-ID: <1430834832-13559-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:54710 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992957AbbEEOHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 10:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Eran's fix is for a small off-by-one introduces on 4.1-rc1.

Yisahi fixes an issue with comes into play only on VMs with 
many (> 256) vCPUs.

Or.


Eran Ben Elisha (1):
  net/mlx4_en: Fix off-by-one in counters manipulation

Yishai Hadas (1):
  net/mlx4_core: Work properly with EQ numbers > 256 in SRIOV

 drivers/net/ethernet/mellanox/mlx4/en_port.c       |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)
