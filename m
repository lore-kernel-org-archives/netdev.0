From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH 2/3] net: mv643xx_eth: fix orphaned statistics timer
 crash
Date: Wed, 2 Oct 2013 08:20:41 -0400
Message-ID: <20131002122041.GJ31178@titan.lakedaemon.net>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1380711442-24735-3-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380711442-24735-3-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:57:21PM +0200, Sebastian Hesselbarth wrote:
> The periodic statistics timer gets started at port _probe() time, but
> is stopped on _stop() only. In a modular environment, this can cause
> the timer to access already deallocated memory, if the module is unloaded
> without starting the eth device. To fix this, we add the timer right
> before the port is started, instead of at _probe() time.
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
>  drivers/net/ethernet/marvell/mv643xx_eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Jason Cooper <jason@lakedaemon.net>

Introduced by:

  4ff3495a mv643xx_eth: enforce frequent hardware statistics polling

which also goes all the way back to v2.6.28

thx,

Jason.
