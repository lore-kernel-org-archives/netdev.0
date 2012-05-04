From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_peek()/skb_peek_tail() cleanups
Date: Fri, 04 May 2012 10:52:24 -0400 (EDT)
Message-ID: <20120504.105224.581648992266748388.davem@davemloft.net>
References: <1335839506.11396.17.camel@edumazet-glaptop>
	<20120501.094127.190023878792795840.davem@davemloft.net>
	<1336136491.3752.318.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54076 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab2EDOw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 10:52:27 -0400
In-Reply-To: <1336136491.3752.318.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 May 2012 15:01:31 +0200

> On Tue, 2012-05-01 at 09:41 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 01 May 2012 04:31:46 +0200
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > remove useless casts and rename variables for less confusion.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> Applied, I really need to get back to completing the list_head
>> conversion :-/
> 
> Actually doubly linked lists everywhere has a performance issue.
> 
> When we dequeue one skb, we must bring in cpu cache the next skb as
> well, to perform the unlink.
> 
> In some places it would be better to not have a double linked list, and
> only perform a prefetch(skb->next).

Indeed, I'll keep this in mind.
