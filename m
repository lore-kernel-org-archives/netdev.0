From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH][ATM]: [drivers] use msleep() instead of schedule_timeout() (from Nishanth Aravamudan <nacc@us.ibm.com>)
Date: Thu, 23 Sep 2004 09:07:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923160710.GB1699@us.ibm.com>
References: <200409212029.i8LKTINv010576@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com, kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200409212029.i8LKTINv010576@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 04:29:19PM -0400, chas williams (contractor) wrote:

<snip>
> diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
> --- a/drivers/atm/lanai.c	2004-09-21 12:48:17 -04:00
> +++ b/drivers/atm/lanai.c	2004-09-21 12:48:17 -04:00
> @@ -813,7 +813,7 @@
>  			DPRINTK("read, write = %d, %d\n", read, write);
>  			break;
>  		}
> -		schedule_timeout(HZ / 25);
> +		msleep(4);

Somehow this got changed for msleep(40); to msleep(4); !! :) The patch I
sent on 15 September had msleep(40); in it, at least. If you could make
the change in your bk, that would be great!

-Nish
