From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net/mlx4_core: clean up srq_res_start_move_to()
Date: Thu, 16 Jan 2014 16:05:17 -0800 (PST)
Message-ID: <20140116.160517.1449593192794233083.davem@davemloft.net>
References: <1389099734.15032.20.camel@x41>
	<20140114084050.70a612af@jpm-OptiPlex-GX620>
	<1389728812.28068.9.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	ronye@mellanox.com, hadarh@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389728812.28068.9.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 14 Jan 2014 20:46:52 +0100

> Building resource_tracker.o triggers a GCC warning:
>     drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_HW2SW_SRQ_wrapper':
>     drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3202:17: warning: 'srq' may be used uninitialized in this function [-Wmaybe-uninitialized]
>       atomic_dec(&srq->mtt->ref_count);
>                      ^
> 
> This is a false positive. But a cleanup of srq_res_start_move_to() can
> help GCC here. The code currently uses a switch statement where a plain
> if/else would do, since only two of the switch's four cases can ever
> occur. Dropping that switch makes the warning go away.
> 
> While we're at it, add some missing braces, and convert state to the
> correct type.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
