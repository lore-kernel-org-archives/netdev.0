From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 11/42] mlxsw: spectrum: Add router interface
 struct
Date: Fri, 1 Jul 2016 10:16:23 -0600
Message-ID: <90c0b9d3-6d54-c4f1-407f-0f93c12caf5d@cumulusnetworks.com>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
 <1467381910-3445-12-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	tgraf@suug.ch, jhs@mojatatu.com, linville@tuxdriver.com,
	ivecera@redhat.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34607 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbcGAQQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 12:16:19 -0400
Received: by mail-io0-f180.google.com with SMTP id g13so103558088ioj.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 09:16:19 -0700 (PDT)
In-Reply-To: <1467381910-3445-12-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/16 8:04 AM, Jiri Pirko wrote:
> @@ -327,6 +333,19 @@ mlxsw_sp_port_vport_find_by_fid(const struct mlxsw_sp_port *mlxsw_sp_port,
>  	return NULL;
>  }
>
> +static inline struct mlxsw_sp_rif *
> +mlxsw_sp_rif_find_by_dev(const struct mlxsw_sp *mlxsw_sp,
> +			 const struct net_device *dev)
> +{
> +	int i;
> +
> +	for (i = 0; i < MLXSW_SP_RIF_MAX; i++)
> +		if (mlxsw_sp->rifs[i] && mlxsw_sp->rifs[i]->dev == dev)
> +			return mlxsw_sp->rifs[i];
> +
> +	return NULL;
> +}
> +

Why not add the rif to mlxsw_sp_port which is the priv data for a mlxsw dev?
