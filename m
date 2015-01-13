From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx5: avoid build warnings on 32-bit
Date: Tue, 13 Jan 2015 17:08:35 -0500 (EST)
Message-ID: <20150113.170835.117518742562457914.davem@davemloft.net>
References: <4105686.Jz5UR0277i@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eli@mellanox.com,
	linux-rdma@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36654 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbAMWIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:08:38 -0500
In-Reply-To: <4105686.Jz5UR0277i@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 13 Jan 2015 17:08:06 +0100

> The mlx5 driver passes a string pointer in through a 'u64' variable,
> which on 32-bit machines causes a build warning:
> 
> drivers/net/ethernet/mellanox/mlx5/core/debugfs.c: In function 'qp_read_field':
> drivers/net/ethernet/mellanox/mlx5/core/debugfs.c:303:11: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
> 
> The code is in fact safe, so we can shut up the warning by adding
> extra type casts.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
