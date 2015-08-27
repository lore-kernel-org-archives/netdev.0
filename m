From: Joe Perches <joe@perches.com>
Subject: Re: [patch net-next v2 2/3] mlxsw: adjust transmit fail log message
 level in __mlxsw_emad_transmit
Date: Thu, 27 Aug 2015 10:56:20 -0700
Message-ID: <1440698180.11525.98.camel@perches.com>
References: <1440691197-25780-1-git-send-email-jiri@resnulli.us>
	 <1440691197-25780-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0095.hostedemail.com ([216.40.44.95]:58160 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751329AbbH0R4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 13:56:24 -0400
In-Reply-To: <1440691197-25780-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-27 at 17:59 +0200, Jiri Pirko wrote:
> When transmit fails, it is an error, not a warning.
[]
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
[]
> @@ -376,8 +376,8 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
>  
>  	err = mlxsw_core_skb_transmit(mlxsw_core->driver_priv, skb, tx_info);
>  	if (err) {
> -		dev_warn(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
> -			 mlxsw_core->emad.tid);
> +		dev_err(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
> +			mlxsw_core->emad.tid);

dev_err_ratelimited?
