From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/2] mlx4_en fixes for 4.7-rc
Date: Tue, 21 Jun 2016 14:20:01 +0300
Message-ID: <1466508003-13835-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57686 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751663AbcFUL1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 07:27:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This small patchset includes two fixes for mlx4_en driver.

One allows a clean shutdown even when clients do not release their
netdev reference.
The other adds error return values to the VLAN VID add/kill functions.

Eran Ben Elisha (1):
  net/mlx4_en: Avoid unregister_netdev at shutdown flow

Kamal Heib (1):
  net/mlx4_en: Fix the return value of a failure in VLAN VID add/kill

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 35 +++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/main.c      |  5 +++-
 include/linux/mlx4/device.h                    |  1 +
 3 files changed, 31 insertions(+), 10 deletions(-)

-- 
1.8.3.1
