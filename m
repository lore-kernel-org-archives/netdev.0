From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: copy_rtnl_link_stats64()
 simplification
Date: Mon, 23 Aug 2010 19:14:52 +0100
Message-ID: <1282587292.2267.47.camel@achroite.uk.solarflarecom.com>
References: <1282583676.2486.525.camel@edumazet-laptop>
	 <1282585624.1879.103.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:30894 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559Ab0HWSO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 14:14:56 -0400
In-Reply-To: <1282585624.1879.103.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-23 at 10:47 -0700, Joe Perches wrote:
> On Mon, 2010-08-23 at 19:14 +0200, Eric Dumazet wrote:
> > No need to use a temporary struct rtnl_link_stats64 variable,
> > just copy the source to skb buffer.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Maybe it's better to use the same argument style as copy_rtnl_link_stats
[...]

I believe the destination pointer is typed as void * because it may not
be naturally aligned for u64.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

