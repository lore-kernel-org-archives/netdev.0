From: Elad Raz <eladr@mellanox.com>
Subject: Re: [patch] mlxsw: fix SWITCHDEV_OBJ_ID_PORT_MDB
Date: Wed, 13 Jan 2016 12:33:14 +0000
Message-ID: <DA3FDF74-E3BD-474B-8C38-E21CAEEFE1DB@mellanox.com>
References: <20160113122823.GD19993@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113122823.GD19993@mwanda>
Content-Language: en-US
Content-ID: <E421F8D9B858184C9B20DA30E74C3EA6@eurprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Jan 13, 2016, at 2:28 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> There is a missing break statement so we always return -EOPNOTSUPP.
> 
> Fixes: 3a49b4fde2a1 ('mlxsw: Adding layer 2 multicast support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Elad Raz <eladr@mellanox.com>

> 
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
> index ffe894e..45479ef 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
> @@ -1015,6 +1015,7 @@ static int mlxsw_sp_port_obj_del(struct net_device *dev,
> 	case SWITCHDEV_OBJ_ID_PORT_MDB:
> 		err = mlxsw_sp_port_mdb_del(mlxsw_sp_port,
> 					    SWITCHDEV_OBJ_PORT_MDB(obj));
> +		break;
> 	default:
> 		err = -EOPNOTSUPP;
> 		break;
