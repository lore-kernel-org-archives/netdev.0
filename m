From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] [Trivial] remove unnecessary header file inclusion
Date: Fri, 13 Sep 2013 17:11:27 +0100
Message-ID: <1379088687.2438.13.camel@bwh-desktop.uk.level5networks.com>
References: <20130913145718.GA2536@will>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: ZHAO Gang <gamerh2o@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49012 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab3IMQLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 12:11:34 -0400
In-Reply-To: <20130913145718.GA2536@will>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-09-13 at 22:57 +0800, ZHAO Gang wrote:
> file linux/fib_rules.h doesn't exist, so remove it.

Do you think people wouldn't notice #include of a nonexistent file?  gcc
is quite good at complaining about them...

It's now called include/uapi/linux/fib_rules.h.

Ben.

> Signed-off-by: ZHAO Gang <gamerh2o@gmail.com>
> ---
>  include/net/fib_rules.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> index 4b2b557..c816f91 100644
> --- a/include/net/fib_rules.h
> +++ b/include/net/fib_rules.h
> @@ -4,7 +4,6 @@
>  #include <linux/types.h>
>  #include <linux/slab.h>
>  #include <linux/netdevice.h>
> -#include <linux/fib_rules.h>
>  #include <net/flow.h>
>  #include <net/rtnetlink.h>
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
