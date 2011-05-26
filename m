From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/3] net: Kill ratelimit.h dependency in linux/net.h
Date: Thu, 26 May 2011 14:24:04 -0700
Message-ID: <1306445044.25717.0.camel@Joe-Laptop>
References: <20110526.164330.2076981043593394399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2088 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758173Ab1EZVYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 17:24:06 -0400
In-Reply-To: <20110526.164330.2076981043593394399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-26 at 16:43 -0400, David Miller wrote:
> Ingo Molnar noticed that we have this unnecessary ratelimit.h
> dependency in linux/net.h, which hid compilation problems from
> people doing builds only with CONFIG_NET enabled.
> 
> Move this stuff out to a seperate net/net_ratelimit.h file and
> include that in the only two places where this thing is needed.

git add net/net_ratelimit.h?

> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  include/linux/net.h        |    6 ------
>  net/core/sysctl_net_core.c |    1 +
>  net/core/utils.c           |    1 +


