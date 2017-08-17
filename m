From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 11/15] net/mlx5e: Properly indent within conditional
 statements
Date: Thu, 17 Aug 2017 14:18:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0059721@AcuExch.aculab.com>
References: <20170817133003.16900-1-saeedm@mellanox.com>
 <20170817133003.16900-12-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: 'Saeed Mahameed' <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:50999 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752261AbdHQOSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 10:18:35 -0400
In-Reply-To: <20170817133003.16900-12-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed
> Sent: 17 August 2017 14:30
> To: David S. Miller
> Cc: netdev@vger.kernel.org; Leon Romanovsky; Or Gerlitz; Saeed Mahameed
> Subject: [net-next 11/15] net/mlx5e: Properly indent within conditional statements
> 
> From: Or Gerlitz <ogerlitz@mellanox.com>
> 
> To fix these checkpatch complaints:
> 
> WARNING: suspect code indent for conditional statements (8, 24)
> +       if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
> [...]
> +                       return PORT_FIBRE;
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> index a75ac4d11c5b..ed161312a773 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> @@ -988,23 +988,23 @@ static u8 get_connector_port(u32 eth_proto, u8 connector_type)
>  		return ptys2connector_type[connector_type];
> 
>  	if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
> -			 | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
> -			 | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
> -			 | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
> -			return PORT_FIBRE;
> +	    | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
> +	    | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
> +	    | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
> +		return PORT_FIBRE;

Gah, that is why the rules are stupid.
If anything the continuation lines want indenting a few more bytes.

	David
