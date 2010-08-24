From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: copy_rtnl_link_stats64()
 simplification
Date: Mon, 23 Aug 2010 20:44:55 -0700 (PDT)
Message-ID: <20100823.204455.22027860.davem@davemloft.net>
References: <1282583676.2486.525.camel@edumazet-laptop>
	<1282585624.1879.103.camel@Joe-Laptop>
	<1282587292.2267.47.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54139
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753262Ab0HXDoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 23:44:37 -0400
In-Reply-To: <1282587292.2267.47.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 23 Aug 2010 19:14:52 +0100

> On Mon, 2010-08-23 at 10:47 -0700, Joe Perches wrote:
>> On Mon, 2010-08-23 at 19:14 +0200, Eric Dumazet wrote:
>> > No need to use a temporary struct rtnl_link_stats64 variable,
>> > just copy the source to skb buffer.
>> > 
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Maybe it's better to use the same argument style as copy_rtnl_link_stats
> [...]
> 
> I believe the destination pointer is typed as void * because it may not
> be naturally aligned for u64.

Exactly right.
