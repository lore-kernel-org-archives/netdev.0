From: David Miller <davem@davemloft.net>
Subject: Re: [pull request][net 0/6] Mellanox mlx5 fixes 2017-06-14
Date: Thu, 15 Jun 2017 22:23:48 -0400 (EDT)
Message-ID: <20170615.222348.452359503802011822.davem@davemloft.net>
References: <20170615205530.26674-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42184 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdFPCXx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 22:23:53 -0400
In-Reply-To: <20170615205530.26674-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 15 Jun 2017 23:55:24 +0300

> This series contains some fixes for the mlx5 core and netdev driver.
> 
> Please pull and let me know if there's any problem.

Pulled.

> For -stable:
> ("net/mlx5: Wait for FW readiness before initializing command interface") kernels >= 4.4
> ("net/mlx5e: Fix timestamping capabilities reporting") kernels >= 4.5
> ("net/mlx5e: Avoid doing a cleanup call if the profile doesn't have it") kernels >= 4.9
> ("net/mlx5e: Fix min inline value for VF rep SQs") kernels >= 4.11
> 
> The "net/mlx5e: Fix min inline .." (a oneliner patch) doesn't cleanly apply
> to 4.11, it hits a contextual conflict and can be easily resolved by:
> +       mlx5_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
> to the end of mlx5e_build_rep_netdev_priv. Note the 2nd parameter of
> mlx5_query_min_inline is slightly different from the original one.

Queued up, thanks!
