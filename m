From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: copy_rtnl_link_stats64()
 simplification
Date: Mon, 23 Aug 2010 20:45:07 -0700 (PDT)
Message-ID: <20100823.204507.26936954.davem@davemloft.net>
References: <1282583676.2486.525.camel@edumazet-laptop>
	<1282584096.2267.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54146
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753928Ab0HXDot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:44:49 -0400
In-Reply-To: <1282584096.2267.34.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 Aug 2010 18:21:36 +0100

> On Mon, 2010-08-23 at 19:14 +0200, Eric Dumazet wrote:
>> No need to use a temporary struct rtnl_link_stats64 variable,
>> just copy the source to skb buffer.
> 
> Yes, this makes sense.
> 
> The reason I didn't do this initially was that I was concerned about
> possible tearing of asynchronously-updated stats.  Since you made
> dev_get_stats() copy into a caller-provided buffer, this is no longer a
> concern.
> 
> For what it's worth:
> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
