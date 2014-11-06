From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net 0/2] mlx5_core fixes for 3.18
Date: Thu,  6 Nov 2014 12:51:20 +0200
Message-ID: <1415271082-7644-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	ogerlitz@mellanox.com, Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:56812 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaKFKvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 05:51:31 -0500
Received: by mail-wi0-f169.google.com with SMTP id n3so1026898wiv.0
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 02:51:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
the following two patches fix races to could lead to kernel panic in some cases.

Thanks,
Eli

Eli Cohen (2):
  net/mlx5_core: Fix race in create EQ
  net/mlx5_core: Fix race on driver load

 drivers/net/ethernet/mellanox/mlx5/core/eq.c   | 7 +++----
 drivers/net/ethernet/mellanox/mlx5/core/main.c | 4 ++--
 2 files changed, 5 insertions(+), 6 deletions(-)

-- 
2.1.2
