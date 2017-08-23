From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 10/15] net/mlx5: Add a blank line after declarations
Date: Wed, 23 Aug 2017 15:39:01 -0700
Message-ID: <1503527941.27867.2.camel@perches.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
         <20170817133003.16900-11-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0196.hostedemail.com ([216.40.44.196]:47943 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751085AbdHWXQM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 19:16:12 -0400
In-Reply-To: <20170817133003.16900-11-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-17 at 16:29 +0300, Saeed Mahameed wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
[]
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
[]
> @@ -188,6 +188,7 @@ static enum mlx5_dev_event port_subtype_event(u8 subtype)
>  static void eq_update_ci(struct mlx5_eq *eq, int arm)
>  {
>  	__be32 __iomem *addr = eq->doorbell + (arm ? 0 : 2);
> +
>  	u32 val = (eq->cons_index & 0xffffff) | (eq->eqn << 24);
>  	__raw_writel((__force u32)cpu_to_be32(val), addr);
>  	/* We still want ordering, just not swabbing, so add a barrier */

checkpatch is stupid.

The blank line should be after u32 val = ...
and not after __be32 __iomem *addr = ...
