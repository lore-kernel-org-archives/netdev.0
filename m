From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH net-next 0/2] mlx4_en: Add PTP support
Date: Tue, 17 Dec 2013 14:32:37 -0600
Message-ID: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, tomk@rgmadvisors.com,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:47649 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab3LQUcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:32:54 -0500
Received: by mail-ob0-f177.google.com with SMTP id vb8so6872269obc.22
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 12:32:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

This adds support to the mlx4_en driver to support running a PTP client
with hardware timestamp support.  It also allows synchronization of the
hardware timestamped packets with the system clock.  

Shawn Bohrer (2):
  mlx4_en: Add PTP hardware clock
  mlx4_en: Only cycle port if HW timestamp config changes

 drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  196 ++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |    3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    6 +
 4 files changed, 200 insertions(+), 8 deletions(-)

-- 
1.7.7.6
