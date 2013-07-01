From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for/net-next 3/8] net/mlx5: Mellanox Connect-IB, core
 driver part 3/3
Date: Mon, 01 Jul 2013 12:18:54 -0700 (PDT)
Message-ID: <20130701.121854.1781783893978810119.davem@davemloft.net>
References: <1372256537-21328-4-git-send-email-ogerlitz@mellanox.com>
	<20130628.211041.256072234719301298.davem@davemloft.net>
	<201307011444.55361.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, roland@kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	eli@dev.mellanox.co.il, moshel@mellanox.com, eli@mellanox.com
To: jackm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab3GATSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 15:18:54 -0400
In-Reply-To: <201307011444.55361.jackm@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Date: Mon, 1 Jul 2013 14:44:54 +0300

> On Saturday 29 June 2013 07:10, David Miller wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>> Date: Wed, 26 Jun 2013 17:22:12 +0300
>> 
>> > +	for (--i; i >= 0; --i) {
>> 
>> Please, "i--" is more canonical in for() loops.
>> 
>> > +	for (--i; i >= 0; --i) {
>> 
>> Likewise.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> Hi Dave,
> 
> For the "for" loop initial value, "i" should be decremented before doing any
> for-loop calculations (and it is not at all obvious if this is the ordering if we use
> i--, and not --i).  Using --i in the initial value makes the ordering obvious.
> However, I do agree with respect to the increment that --i and i-- are logically
> identical.
> 
> Thus, the "for" loop could read:
> 	for (--i; i >= 0; i--) {
> 
> However, my own personal opinion is that this is a bit confusing.
> I would prefer to leave these lines as they are.
> 
> Is that OK with you?

Actually, you should adjust both decrements to read "i--".

Look, if someone doesn't grok that the leftmost decrement happens
before any of the loop body or tests, they don't understand how
for() loops work.

And you're syntax is just confusing people who actually _do_
understand how this part of the C language operates.
