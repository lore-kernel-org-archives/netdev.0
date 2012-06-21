From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 0/4] net/mlx4: Bug fixes for the mlx4_en driver
Date: Thu, 21 Jun 2012 12:19:13 +0300
Message-ID: <1340270358-19504-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:54507 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932301Ab2FUJTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 05:19:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a set of 4 bug fixes generated agains net tree:

Yevgeny Petrilin (4):
	net/mlx4_en: Set correct port parameters during device initialization
	net/mlx4: Use single completion vector after NOP failure
	net/mlx4_en: Release QP range in free_resources
	net/mlx4_en: Use atomic counter to decide when queue is full

 en_netdev.c |   18 ++++++++++++------
 en_tx.c     |   16 ++++++++--------
 main.c      |    2 ++
 mlx4_en.h   |    2 ++
 4 files changed, 24 insertions(+), 14 deletions(-)

Thanks,
Yevgeny
