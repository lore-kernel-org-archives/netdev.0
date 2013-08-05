From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH 4/4] net: mlx4: Staticize local functions
Date: Mon, 5 Aug 2013 14:13:10 +0300
Message-ID: <51FF88C6.7060803@mellanox.com>
References: <002401ce91ba$d8025860$88070920$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	'Yevgeny Petrilin' <yevgenyp@mellanox.com>,
	'Eugenia Emantayev' <eugenia@mellanox.com>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:44463 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754074Ab3HELNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 07:13:20 -0400
In-Reply-To: <002401ce91ba$d8025860$88070920$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2013 12:04, Jingoo Han wrote:
> These local functions are used only in this file.
> Fix the following sparse warnings:
> 
> drivers/net/ethernet/mellanox/mlx4/cmd.c:803:5: warning: symbol 'MLX4_CMD_UPDATE_QP_wrapper' was not declared. Should it be static?
> drivers/net/ethernet/mellanox/mlx4/cmd.c:812:5: warning: symbol 'MLX4_CMD_GET_OP_REQ_wrapper' was not declared. Should it be static?
> drivers/net/ethernet/mellanox/mlx4/cmd.c:1547:5: warning: symbol 'mlx4_master_immediate_activate_vlan_qos' was not declared. Should
> it be static?
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/cmd.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> index 141322c..ea20182 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
> @@ -800,7 +800,7 @@ static int mlx4_MAD_IFC_wrapper(struct mlx4_dev *dev, int slave,
>  				    vhcr->op, MLX4_CMD_TIME_CLASS_C, MLX4_CMD_NATIVE);
>  }
>  
> -int MLX4_CMD_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
> +static int MLX4_CMD_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
>  		     struct mlx4_vhcr *vhcr,
>  		     struct mlx4_cmd_mailbox *inbox,
>  		     struct mlx4_cmd_mailbox *outbox,
> @@ -809,7 +809,7 @@ int MLX4_CMD_UPDATE_QP_wrapper(struct mlx4_dev *dev, int slave,
>  	return -EPERM;
>  }
>  
> -int MLX4_CMD_GET_OP_REQ_wrapper(struct mlx4_dev *dev, int slave,
> +static int MLX4_CMD_GET_OP_REQ_wrapper(struct mlx4_dev *dev, int slave,
>  		     struct mlx4_vhcr *vhcr,
>  		     struct mlx4_cmd_mailbox *inbox,
>  		     struct mlx4_cmd_mailbox *outbox,
> @@ -1544,7 +1544,7 @@ static int calculate_transition(u16 oper_vlan, u16 admin_vlan)
>  	return (2 * (oper_vlan == MLX4_VGT) + (admin_vlan == MLX4_VGT));
>  }
>  
> -int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
> +static int mlx4_master_immediate_activate_vlan_qos(struct mlx4_priv *priv,
>  					    int slave, int port)
>  {
>  	struct mlx4_vport_oper_state *vp_oper;
> 

Acked-By: Amir Vadai <amirv@mellanox.com>
