From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 1/3] net: mv643xx_eth: update statistics timer from
 timer context only
Date: Wed, 2 Oct 2013 08:17:01 -0400
Message-ID: <20131002121701.GI31178@titan.lakedaemon.net>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1380711442-24735-2-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380711442-24735-2-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:57:20PM +0200, Sebastian Hesselbarth wrote:
> Each port driver installs a periodic timer to update port statistics
> by calling mib_counters_update. As mib_counters_update is also called
> from non-timer context, we should not reschedule the timer there but
> rather move it to timer-only context.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: David Miller <davem@davemloft.net>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/ethernet/marvell/mv643xx_eth.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)

Acked-by: Jason Cooper <jason@lakedaemon.net>

Introduced by:

  4ff3495a mv643xx_eth: enforce frequent hardware statistics polling

which goes all the way back to v2.6.28

thx,

Jason.
