From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [patch 1/1] net/pcnet32: replace schedule_timeout() with msleep_interruptible()
Date: Tue, 11 Jan 2005 16:04:58 -0800
Message-ID: <20050112000458.GA17834@us.ibm.com>
References: <20050111230150.1B6141F225@trashy.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsbogend@alpha.franken.de, netdev@oss.sgi.com, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: domen@coderock.org
Content-Disposition: inline
In-Reply-To: <20050111230150.1B6141F225@trashy.coderock.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Looks and runs fine.

Signed-off-by: Don Fry <brazilnut@us.ibm.com>

On Wed, Jan 12, 2005 at 12:01:49AM +0100, domen@coderock.org wrote:
> 
> 
> 
> Any comments would be appreciated.
> 
> Description: Use msleep_interruptible() instead of schedule_timeout() to
> guarantee the task delays as expected.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
> Signed-off-by: Domen Puncer <domen@coderock.org>
> ---
> 
> 
>  kj-domen/drivers/net/pcnet32.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32 drivers/net/pcnet32.c
> --- kj/drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32	2005-01-10 18:00:07.000000000 +0100
> +++ kj-domen/drivers/net/pcnet32.c	2005-01-10 18:00:07.000000000 +0100
> @@ -847,7 +847,7 @@ static int pcnet32_phys_id(struct net_de
>      if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
>      data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
>  
> -    schedule_timeout(data * HZ);
> +    msleep_interruptible(data * 1000);
>      del_timer_sync(&lp->blink_timer);
>  
>      /* Restore the original value of the bcrs */
> _
> 
> 

-- 
Don Fry
brazilnut@us.ibm.com
