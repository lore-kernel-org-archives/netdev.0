From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] codel: refine one condition to avoid a nul rec_inv_sqrt
Date: Fri, 10 Aug 2012 16:54:05 -0700 (PDT)
Message-ID: <20120810.165405.284352377586092244.davem@davemloft.net>
References: <1343631141.2626.13293.camel@edumazet-glaptop>
	<20120730.145412.1689803770003231369.davem@davemloft.net>
	<1344611771.31104.2716.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lp2s1h@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46740 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760187Ab2HJXyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 19:54:05 -0400
In-Reply-To: <1344611771.31104.2716.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Aug 2012 17:16:11 +0200

> On Mon, 2012-07-30 at 14:54 -0700, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 30 Jul 2012 08:52:21 +0200
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > One condition before codel_Newton_step() was not good if
>> > we never left the dropping state for a flow. As a result
>> > rec_inv_sqrt was 0, instead of the ~0 initial value.
>> > 
>> > codel control law was then set to a very aggressive mode, dropping
>> > many packets before reaching 'target' and recovering from this problem.
>> > 
>> > To keep codel_vars_init() as efficient as possible, refine
>> > the condition to make sure rec_inv_sqrt initial value is correct
>> > 
>> > Many thanks to Anton Mich for discovering the issue and suggesting
>> > a fix.
>> > 
>> > Reported-by: Anton Mich <lp2s1h@gmail.com>
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> Applied and queued up for -stable.
> 
> Hi David, I think this patch got lost somehow ?

Thanks for catching this, I've corrected it now.
