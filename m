From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 11/12] mlxsw: spectrum_dpipe: Add support for
 IPv4 host table dump
Date: Thu, 24 Aug 2017 12:26:35 -0700
Message-ID: <e5af97b0-c17b-5360-69f7-8d1428960258@gmail.com>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-12-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35709 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753713AbdHXT0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 15:26:38 -0400
Received: by mail-pg0-f67.google.com with SMTP id r133so588197pgr.2
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 12:26:37 -0700 (PDT)
In-Reply-To: <20170824064010.1646-12-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/17 11:40 PM, Jiri Pirko wrote:
> +static int
> +mlxsw_sp_dpipe_table_host_entries_get(struct mlxsw_sp *mlxsw_sp,
> +				      struct devlink_dpipe_entry *entry,
> +				      bool counters_enabled,
> +				      struct devlink_dpipe_dump_ctx *dump_ctx,
> +				      int type)
> +{
> +	int rif_neigh_count = 0;
> +	int rif_neigh_skip = 0;
> +	int neigh_count = 0;
> +	int rif_count;
> +	int i, j;
> +	int err;
> +
> +	rtnl_lock();

Why does a h/w driver dumping its tables need the rtnl lock?
