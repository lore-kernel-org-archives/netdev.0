From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 0/8] net/mlx4: Performance enhancement and cleanups
Date: Tue, 6 Mar 2012 16:03:29 +0200
Message-ID: <4F561931.1000002@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:42007 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758264Ab2CFODf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:03:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
This patch consists of a patch with datapath pointer optimizations, which was submitted a week ago
and you agreed to accept it after resubmission.
In addition, there are 7 cleanup patches that remove sparse warnings for mlx4 drivers.

Or Gerlitz (2):
  net/mlx4: fix sparse warnings on TX control flags endianess
  net/mlx4: fix sparse warnings on TX blue flame buffer

Yevgeny Petrilin (6):
  net/mlx4_en: Saving mem access on data path
  net/mlx4: fix sparse warnings on wrong type for RSS keys
  net/mlx4: fixing sparse warnings when copying mac address to gid entry
  net/mlx4: fixing sparse warnings for not declared functions
  net/mlx4: remove unused functions
  net/mlx4: defining functions as static



 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |   16 +---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   15 ++--
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   10 ---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    7 --
 drivers/net/ethernet/mellanox/mlx4/mr.c        |   81 -------------------------
 drivers/net/ethernet/mellanox/mlx4/port.c      |   10 +--
 include/linux/mlx4/device.h                    |    5 +
 8 files changed, 28 insertions(+), 117 deletions(-)
