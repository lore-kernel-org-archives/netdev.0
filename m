From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] drivers/net/ethernet/mellanox/mlx5/core/en_main.c:
 fix build with gcc-4.4.4
Date: Sun, 02 Apr 2017 19:33:26 -0700 (PDT)
Message-ID: <20170402.193326.404525218121744191.davem@davemloft.net>
References: <58deb782.4aWRKEOlfxaAvBBc%akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, tariqt@mellanox.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41352 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751280AbdDCCd3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 22:33:29 -0400
In-Reply-To: <58deb782.4aWRKEOlfxaAvBBc%akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 31 Mar 2017 13:09:38 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: drivers/net/ethernet/mellanox/mlx5/core/en_main.c: fix build with gcc-4.4.4
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_redirect_rqts':
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2210: error: unknown field 'rqn' specified in initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2211: warning: missing braces around initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2211: warning: (near initialization for 'direct_rrp.<anonymous>')
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_redirect_rqts_to_channels':
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: error: unknown field 'rss' specified in initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: warning: missing braces around initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: warning: (near initialization for 'rrp.<anonymous>')
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2227: warning: initialization makes integer from pointer without a cast
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2228: error: unknown field 'rss' specified in initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2229: warning: excess elements in struct initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2229: warning: (near initialization for 'rrp')
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c: In function 'mlx5e_redirect_rqts_to_drop':
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2238: error: unknown field 'rqn' specified in initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2239: warning: missing braces around initializer
> drivers/net/ethernet/mellanox/mlx5/core/en_main.c:2239: warning: (near initialization for 'drop_rrp.<anonymous>')
> 
> gcc-4.4.4 has issues with anonymous union initializers.  Work around this.
> 
> Cc: Saeed Mahameed <saeedm@mellanox.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
