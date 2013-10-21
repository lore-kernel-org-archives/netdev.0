From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v2 0/3] UFO fixes
Date: Mon, 21 Oct 2013 16:26:12 -0400 (EDT)
Message-ID: <20131021.162612.1795347771078720888.davem@davemloft.net>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
	<20131019.192147.1905247570882389108.davem@davemloft.net>
	<20131020032617.GA27787@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	jdmason@kudzu.us, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937Ab3JUU0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 16:26:14 -0400
In-Reply-To: <20131020032617.GA27787@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 20 Oct 2013 05:26:17 +0200

> Hi David!
> 
> On Sat, Oct 19, 2013 at 07:21:47PM -0400, David Miller wrote:
>> From: Jiri Pirko <jiri@resnulli.us>
>> Date: Sat, 19 Oct 2013 12:29:14 +0200
>> 
>> > Couple of patches fixing UFO functionality in different situations.
>> > 
>> > v1->v2:
>> > - minor if{}else{} coding style adjustment suggested by Sergei Shtylyov
>> 
>> Series applied, thanks Jiri.
> 
> I would propose that the patches
> 
> "ip6_output: do skb ufo init for peeked non ufo skb as well"
> (c547dbf55d5f8cf615ccc0e7265e98db27d3fb8b)
> 
> and
> 
> "ip_output: do skb ufo init for peeked non ufo skb as well"
> (e93b7d748be887cd7639b113ba7d7ef792a7efb9)
> 
> should go to stable because they solve a possible memory corruption
> from userspace.

I suppose... the reason I didn't automatically queue these up for -stable
is that they are rather non-trivial.
