From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 11/18]  net/pcnet32: replace 	schedule_timeout() with
 msleep_interruptible()
Date: Sun, 31 Oct 2004 06:05:37 -0500
Message-ID: <4184C701.5030103@pobox.com>
References: <E1CO1vx-0002OW-FJ@sputnik>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, nacc@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: janitor@sternwelten.at
In-Reply-To: <E1CO1vx-0002OW-FJ@sputnik>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

janitor@sternwelten.at wrote:
> diff -puN drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32 drivers/net/pcnet32.c
> --- linux-2.6.10-rc1/drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32	2004-10-24 17:05:14.000000000 +0200
> +++ linux-2.6.10-rc1-max/drivers/net/pcnet32.c	2004-10-24 17:05:14.000000000 +0200
> @@ -847,7 +847,7 @@ static int pcnet32_phys_id(struct net_de
>      if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
>      data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
>  
> -    schedule_timeout(data * HZ);
> +    msleep_interruptible(data * 1000);


clearly and obviously ssleep()
