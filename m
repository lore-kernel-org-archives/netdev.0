From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 01:26:07 -0700 (PDT)
Message-ID: <20100415.012607.15449571.davem@davemloft.net>
References: <1271056697.16881.7.camel@edumazet-laptop>
	<20100414.235256.190096561.davem@davemloft.net>
	<1271318553.16881.2161.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40416
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755745Ab0DOI0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:26:04 -0400
In-Reply-To: <1271318553.16881.2161.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Apr 2010 10:02:33 +0200

> Denys got a crash that we cannot explain yet. He said he has no
> multiqueue devices, so obviously my patch cant help him.
> 
> But this patch was fixing a real issue, I believe I pointed it twice
> already...

Ok, I thought your patch was specifically meant to fix Denys's bug.

The confusion comes from the fact that you mention Denys's crash in
your commit message:

--------------------
When dev_pick_tx() caches tx queue_index on a socket, we must check
socket dst_entry matches skb one, or risk a crash later, as reported by
Denys Fedorysychenko, if old packets are in flight during a route
change, involving devices with different number of queues.
--------------------

Anyways, I studied your patch once more and read the thread discussion
with Krishna again and your patch looks fine.  I'll apply it to
net-2.6, thanks!

