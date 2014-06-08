From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/2] mlx4 SRIOV fixes
Date: Sun,  8 Jun 2014 13:49:44 +0300
Message-ID: <1402224586-21187-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46314 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752506AbaFHKtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 06:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

The patch from Wei Yang is a designed fix to a regression introduced by earlier commit
of him. Jack added a fix to the resource management which we got from IBM.

Let's get that into 3.16-rc1 1st and later see to what stable version/s this should go.

Or.

Jack Morgenstein (1):
  net/mlx4_core: Fix SRIOV free-pool management when enforcing resource quotas

Wei Yang (1):
  net/mlx4_core: Keep only one driver entry release mlx4_priv

 drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   41 ++++++++++++++++++--
 2 files changed, 38 insertions(+), 5 deletions(-)
