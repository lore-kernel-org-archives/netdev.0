From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/3] net/mlx5e: Kconfig fixes
Date: Wed,  4 May 2016 14:26:07 +0200
Message-ID: <1462364774-3792510-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de, davem@davemloft.net
To: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:57517 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbcEDM00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 08:26:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I saw two new build errors with invalid configurations on mlx5e, and a
closer look revealed that one of them was caused by a slightly incorrect
fix for which I had sent a different patch when it first broke.

This series reverts the new fix for the VXLAN problem as it caused
another bug, and follows up with a new version of my patch (adapted
as originally requested), and another patch for the simiar RFS
bug that was just introduced.

        Arnd
