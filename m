From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/6] forcedeth: use KERN_ facility level in printk
Date: Sat, 27 Nov 2010 19:04:01 +0000
Message-ID: <1290884641.3292.0.camel@localhost>
References: <1290883188-2078-1-git-send-email-szymon@janc.net.pl>
	 <1290883188-2078-6-git-send-email-szymon@janc.net.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Szymon Janc <szymon@janc.net.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:4014 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab0K0TEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 14:04:07 -0500
In-Reply-To: <1290883188-2078-6-git-send-email-szymon@janc.net.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-11-27 at 19:39 +0100, Szymon Janc wrote:
> Signed-off-by: Szymon Janc <szymon@janc.net.pl>
> ---
>  drivers/net/forcedeth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 2f092d7..a2b6681 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -958,7 +958,7 @@ static int reg_delay(struct net_device *dev, int offset, u32 mask, u32 target,
>  		delaymax -= delay;
>  		if (delaymax < 0) {
>  			if (msg)
> -				printk("%s", msg);
> +				printk(KERN_WARNING "%s", msg);

No, msg already includes a log level.

Ben.

>  			return 1;
>  		}
>  	} while ((readl(base + offset) & mask) != target);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

