From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: msleep changes
Date: Thu, 23 Sep 2004 09:08:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923160810.GC1699@us.ibm.com>
References: <5.1.0.14.2.20040923050120.0257f490@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Margit Schubert-While <margitsw@t-online.de>
Content-Disposition: inline
In-Reply-To: <5.1.0.14.2.20040923050120.0257f490@pop.t-online.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 05:24:33AM +0200, Margit Schubert-While wrote:
> Hi Nish,
> In latest BK :
> 
> # drivers/atm/lanai.c
> # 2004/09/21 14:58:17-07:00 chas@cmf.nrl.navy.mil +1 -1
> # [ATM]: [drivers] Use msleep() instead of schedule_timeout()
> # From Nishanth Aravamudan <nacc@us.ibm.com>
> 
> diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
> --- a/drivers/atm/lanai.c	2004-09-21 17:11:30 -07:00
> +++ b/drivers/atm/lanai.c	2004-09-21 17:11:30 -07:00
> @@ -813,7 +813,7 @@
>  			DPRINTK("read, write = %d, %d\n", read, write);
>  			break;
>  		}
> -		schedule_timeout(HZ / 25);
> +		msleep(4);
> 
> 
> ??????
> 
> Just one that immediately lept to my eye.
> I am not going to check them all.
> That's your job :-)

Thanks for catching this. I actually have re-pushed the patch already
with the correct time, but it is only going to be in the latest kjt
(which was sent yesterday, I think). Ahh, I see the problem; somehow the
maintainer's patch had msleep(4) in it, even though my patch had
msleep(40). It should be corrected soon. Thanks for seeing this, again.

-Nish
