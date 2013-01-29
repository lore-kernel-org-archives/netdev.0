From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: do not create neighbor entries for local delivery
Date: Tue, 29 Jan 2013 16:10:37 -0500 (EST)
Message-ID: <20130129.161037.1891067829834991958.davem@davemloft.net>
References: <50F6ABCA.4020804@redhat.com>
	<20130116.162813.1734293658687337225.davem@davemloft.net>
	<20130129105336.GA7571@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab3A2VKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 16:10:39 -0500
In-Reply-To: <20130129105336.GA7571@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 29 Jan 2013 11:53:36 +0100

> Wed, Jan 16, 2013 at 10:28:13PM CET, davem@davemloft.net wrote:
>>From: Marcelo Ricardo Leitner <mleitner@redhat.com>
>>Date: Wed, 16 Jan 2013 11:31:54 -0200
>>
>>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>>> index
>>> 7c34c01b515b7ac370f8021ba6f5ec4c654e9e41..b63e33bcbdfbc1bd78af0b98ffc2d211805214ea
>>> 100644
>>
>>Patch corrupted by your email client.
>>
>>Note also that YOSHIFUJI Hideaki's patches to remove the cached neighbour
>>entirely from ipv6 routes will have the same effect, so your patch won't
>>be needed.
> 
> Dave, wouldn't this patch be suitable candidate for -net (/-stable) ?
> 
> I can repost this properly.

Ok, please repost, thanks Jiri.
