From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 11/15] net/mlx5e: Reduce number of heap allocated
 buffers for update stats
Date: Tue, 20 Jun 2017 12:36:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0026BD1@AcuExch.aculab.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
 <20170615214252.30140-12-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Gal Pressman <galp@mellanox.com>,
        "kernel-team@fb.com" <kernel-team@fb.com>
To: 'Saeed Mahameed' <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:65515 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdFTMgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 08:36:19 -0400
In-Reply-To: <20170615214252.30140-12-saeedm@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed
> Sent: 15 June 2017 22:43
> Allocating buffers on the heap every 200ms is something we should avoid,
> let's use buffers located on the stack instead.
...
> +	u32 in[MLX5_ST_SZ_DW(ppcnt_reg)] = {0};

How big is that?

Allocating large on-stack buffers is even worse.

One kzalloc() every 200ms isn't going to be noticeable.

	David
