From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 23:14:01 -0700 (PDT)
Message-ID: <20120619.231401.2278176068934152926.davem@davemloft.net>
References: <20120619.214657.1345825814176201681.davem@davemloft.net>
	<1340171359.4604.794.camel@edumazet-glaptop>
	<1340171489.4604.796.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab2FTGOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 02:14:04 -0400
In-Reply-To: <1340171489.4604.796.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 07:51:29 +0200

> On Wed, 2012-06-20 at 07:49 +0200, Eric Dumazet wrote:
> 
>> 2) small lived tcp sessions
>> 
>>    input dst is now dirtied because of the additional
>> dst_clone()/dst_release()
> 
> Not realy a concern because we dirty cache line anyway
> 
> dst_use_noref()
> {
> 	dst->__use++;
> 	dst->lastuse = time;
> }

Right, the costs probably even out for short TCP flows.

But better to do real tests than to believe what any of
us say. :-)
