From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 14:39:26 -0400 (EDT)
Message-ID: <20120425.143926.1031867921141711841.davem@davemloft.net>
References: <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
	<1335346710.3274.24.camel@edumazet-glaptop>
	<1335348157.3274.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tore@fud.no, maze@google.com, netdev@vger.kernel.org,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755652Ab2DYSke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 14:40:34 -0400
In-Reply-To: <1335348157.3274.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Apr 2012 12:02:37 +0200

> On Wed, 2012-04-25 at 11:38 +0200, Eric Dumazet wrote:
> 
>> Hmm, but what if we change linux to choice a) instead of b) ?
>> 
>> That is, not cap mtu to minimum value 1280 (and not use anymore
>> RTAX_FEATURE_ALLFRAG) : dst_allfrag() would be always false.
>> 
>> In this case, do we still need to send the frag header ?
>> 
>> I ask this because some TSO6 implementations probably dont cope very
>> well with this added header (untested path)
>> 
> 
> So a patch against net-next would looks like :
> 
> (Incredible, we remove some code in linux ;) )

I wouldn't mind applying this :-)
