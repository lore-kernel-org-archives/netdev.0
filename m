From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 0/6 V2] mlx4_en: Data path optimizations and bug fix
Date: Tue, 18 Oct 2011 13:50:20 +0200
Message-ID: <4E9D67FC.7000902@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:45184 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753502Ab1JRN6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 09:58:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
This is V2 of the patches sent yesterday.
The differences comparing to V1 are:
1. Remove patch 3/7 : "Incoming traffic alignment optimizations" following Eric's comments for a rework.
2. Using static seed value for Toeplitz function, rather then randomizing the value each time

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.c   |    6 ++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   23 ++++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    2 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c        |    1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    7 +++++--
 drivers/net/ethernet/mellanox/mlx4/port.c      |   15 ++++++++-------
 include/linux/mlx4/device.h                    |    1 +


Thanks,
Yevgeny
