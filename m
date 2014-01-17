From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net/mlx4_core: clean up cq_res_start_move_to()
Date: Thu, 16 Jan 2014 16:05:05 -0800 (PST)
Message-ID: <20140116.160505.2018103158475655301.davem@davemloft.net>
References: <1389099678.15032.19.camel@x41>
	<20140114084752.1db64b21@jpm-OptiPlex-GX620>
	<1389728736.28068.8.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	ronye@mellanox.com, hadarh@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389728736.28068.8.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 14 Jan 2014 20:45:36 +0100

> Building resource_tracker.o triggers a GCC warning:
>     drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_HW2SW_CQ_wrapper':
>     drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3019:16: warning: 'cq' may be used uninitialized in this function [-Wmaybe-uninitialized]
>       atomic_dec(&cq->mtt->ref_count);
>                     ^
> 
> This is a false positive. But a cleanup of cq_res_start_move_to() can
> help GCC here. The code currently uses a switch statement where an
> if/else construct would do too, since only two of the switch's four
> cases can ever occur. Dropping that switch makes the warning go away.
> 
> While we're at it, add some missing braces.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied.
