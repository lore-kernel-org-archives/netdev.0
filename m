From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2]
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: fix build with
 gcc-4.4.4
Date: Sun, 02 Apr 2017 19:33:34 -0700 (PDT)
Message-ID: <20170402.193334.1689358074445514089.davem@davemloft.net>
References: <58deb785.KVe23DdxZZyNjqm4%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, tariqt@mellanox.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdDCCdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 22:33:35 -0400
In-Reply-To: <58deb785.KVe23DdxZZyNjqm4%akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 31 Mar 2017 13:09:41 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: fix build with gcc-4.4.4
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c: In function 'mlx5e_set_rxfh':
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1067: error: unknown field 'rss' specified in initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1067: warning: missing braces around initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1067: warning: (near initialization for 'rrp.<anonymous>')
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1068: error: unknown field 'rss' specified in initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1069: warning: excess elements in struct initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c:1069: warning: (near initialization for 'rrp')
> 
> gcc-4.4.4 has issues with anonymous union initializers.  Work around this.
> 
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
