From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] net/mlx4: two virtualization bug fixes
Date: Thu, 17 Jan 2013 17:30:41 +0200
Message-ID: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:50695 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756558Ab3AQPd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:33:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

These are two fixes to driver bugs which were introduced during the integration 
of the SRIOV patches, would love see them going to -stable too.

Or.


Or Gerlitz (1):
  net/mlx4_core: Set number of msix vectors under SRIOV mode to
    firmware defaults

Yan Burman (1):
  net/mlx4_en: Fix bridged vSwitch configuration for non SRIOV mode

 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   13 +++++++++----
 drivers/net/ethernet/mellanox/mlx4/main.c  |   11 ++---------
 2 files changed, 11 insertions(+), 13 deletions(-)
