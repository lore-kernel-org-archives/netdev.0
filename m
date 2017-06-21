From: Gal Pressman <galp@mellanox.com>
Subject: Re: [net-next 11/15] net/mlx5e: Reduce number of heap allocated
 buffers for update stats
Date: Wed, 21 Jun 2017 11:12:24 +0300
Message-ID: <b692fdcf-e37e-9faa-5c06-af73dd52ee49@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
 <20170615214252.30140-12-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0026BD1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@ACULAB.COM>,
        'Saeed Mahameed' <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0076.outbound.protection.outlook.com ([104.47.2.76]:59915
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751015AbdFUIMb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 04:12:31 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0026BD1@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> +	u32 in[MLX5_ST_SZ_DW(ppcnt_reg)] = {0};
> How big is that?
>
> Allocating large on-stack buffers is even worse.
Both PPCNT and MPCNT registers are 252 bytes.
I don't see a problem allocating them on the stack.
