From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 09 Jun 2009 17:45:04 -0700 (PDT)
Message-ID: <20090609.174504.114047526.davem@davemloft.net>
References: <alpine.DEB.1.10.0906081117580.21954@gentwo.org>
	<20090608.142927.122160930.davem@davemloft.net>
	<adaocsx3zaa.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53922
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751105AbZFJApC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 20:45:02 -0400
In-Reply-To: <adaocsx3zaa.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 09 Jun 2009 13:52:45 -0700

> 
>  > > Maybe we need a different approach but (since we are at the point of
>  > > talking about categorical fundamentally wrong statements) its
>  > > fundamentally wrong if the IPoIB layer works differently from a regular
>  > > Ethernet NIC. They should work in the same way.
>  > 
>  > This I agree on.  When a multicast group is joined, the IPoIB layer
>  > should block in some way until the subscription is fully available
>  > for use.
> 
> Not sure I understand.  What do you mean by block?  It is quite possible
> that a single multicast group is waiting to be joined, while other
> multicast groups and unicast traffic can be sent with no problem.  So
> stopping the whole device queue and blocking everything doesn't seem
> appropriate.

Block the process joining the multicast group, not the entire
interface.
