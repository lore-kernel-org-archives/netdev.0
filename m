From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: copy_rtnl_link_stats64()
 simplification
Date: Mon, 23 Aug 2010 18:21:36 +0100
Message-ID: <1282584096.2267.34.camel@achroite.uk.solarflarecom.com>
References: <1282583676.2486.525.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26055 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751674Ab0HWRVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 13:21:40 -0400
In-Reply-To: <1282583676.2486.525.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 19:14 +0200, Eric Dumazet wrote:
> No need to use a temporary struct rtnl_link_stats64 variable,
> just copy the source to skb buffer.

Yes, this makes sense.

The reason I didn't do this initially was that I was concerned about
possible tearing of asynchronously-updated stats.  Since you made
dev_get_stats() copy into a caller-provided buffer, this is no longer a
concern.

For what it's worth:

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

