From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net V1 0/3] net/mlx4: Bug fixes for the mlx4_en driver
Date: Mon, 25 Jun 2012 13:24:10 +0300
Message-ID: <1340619853-29804-1-git-send-email-yevgenyp@mellanox.co.il>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:39897 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755934Ab2FYNY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 09:24:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a set of 3 bug fixes generated agains net tree:

---
Diff from V1:
Removed atomic counter patch for rework.

Yevgeny Petrilin (3):
	net/mlx4_en: Set correct port parameters during device initialization
	net/mlx4: Use single completion vector after NOP failure
	net/mlx4_en: Release QP range in free_resources

 en_netdev.c |   18 ++++++++++++------
 main.c      |    2 ++
 mlx4_en.h   |    1 +
 3 files changed, 15 insertions(+), 6 deletions(-)

Thanks,
Yevgeny
