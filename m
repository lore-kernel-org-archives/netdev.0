From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/3] mlx4 fixes
Date: Thu, 25 Oct 2012 13:12:46 +0200
Message-ID: <1351163569-17132-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:44969 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758910Ab2JYLM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 07:12:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Few mlx4 driver fixes for net.

thanks,

Or.


Dotan Barak (1):
  net/mlx4_core: Unmap UAR also in the case of error flow

Jack Morgenstein (1):
  net/mlx4_en: Fix double-release-range in tx-rings

Moni Shoua (1):
  net/mlx4_en: Don't use vlan tag value as an indication for vlan presence

 drivers/net/ethernet/mellanox/mlx4/en_tx.c |    3 +--
 drivers/net/ethernet/mellanox/mlx4/eq.c    |   18 ++++++++++++++----
 2 files changed, 15 insertions(+), 6 deletions(-)
