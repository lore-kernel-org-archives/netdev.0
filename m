From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 17:50:44 -0400 (EDT)
Message-ID: <20110517.175044.2057517197524794568.davem@davemloft.net>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<20110517.174431.1004332995189918916.davem@davemloft.net>
	<m262p9yp5f.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932439Ab1EQVuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:50:50 -0400
In-Reply-To: <m262p9yp5f.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 17 May 2011 14:48:28 -0700

> David Miller <davem@davemloft.net> writes:
> 
>> Guys we can't time out fragments if we are not the final
>> destination.
> 
> If you're not the final destination you should never even
> try to reassemble them?
> 
> I'm probably missing something...

We're discussing the idea to do the defragmentation first
so we can choose the flow properly and steer the packet
to the correct cpu.

This also would allos each fragmented packet to traverse the
stack only once (one route lookup etc.) instead of once per
fragment.

Please read the rest of this thread, we have discussed this
and now I'm repeating information solely for your benefit.
