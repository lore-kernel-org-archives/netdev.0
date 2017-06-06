From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 3/3] mlxsw: spectrum_router: Align RIF index
 allocation with existing code
Date: Tue, 6 Jun 2017 09:11:51 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00162A3@AcuExch.aculab.com>
References: <20170604145340.14447-1-jiri@resnulli.us>
 <20170604145340.14447-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "petrm@mellanox.com" <petrm@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>
To: 'Jiri Pirko' <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:58125 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdFFJL7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 05:11:59 -0400
In-Reply-To: <20170604145340.14447-4-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
> Sent: 04 June 2017 15:54
> The way we usually allocate an index is by letting the allocation
> function return an error instead of an invalid index.
...
> -static int mlxsw_sp_avail_rif_get(struct mlxsw_sp *mlxsw_sp)
> +static int mlxsw_sp_rif_index_alloc(struct mlxsw_sp *mlxsw_sp, u16 *p_rif_index)

You typically get much better code from returning an invalid index.
This is why PTR_ERR() exists.

	David
