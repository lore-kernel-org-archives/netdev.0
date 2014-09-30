From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/4] mlx4_core driver updates
Date: Tue, 30 Sep 2014 12:03:46 +0300
Message-ID: <1412067830-30438-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42469 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751653AbaI3JD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Sep 2014 05:03:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

A series from Jack and Co of low-level fixes for the mlx4_core driver

Or.

Jack Morgenstein (3):
  net/mlx4_core: Don't disable SRIOV if there are active VFs
  net/mlx4_core: Protect QUERY_PORT wrapper from untrusted guests
  net/mlx4_core: Deprecate error message at ConnectX-2 cards startup to debug

Majd Dibbiny (1):
  net/mlx4_core: New init and exit flow for mlx4_core

 drivers/net/ethernet/mellanox/mlx4/cmd.c  |   14 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c   |    9 +-
 drivers/net/ethernet/mellanox/mlx4/main.c |  421 ++++++++++++++++-------------
 include/linux/mlx4/device.h               |    1 +
 4 files changed, 260 insertions(+), 185 deletions(-)
