From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 09 Jun 2009 13:52:45 -0700
Message-ID: <adaocsx3zaa.fsf@cisco.com>
References: <alpine.DEB.1.10.0906050959380.23895@gentwo.org>
	<20090605.181613.147549237.davem@davemloft.net>
	<alpine.DEB.1.10.0906081117580.21954@gentwo.org>
	<20090608.142927.122160930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:5455 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbZFIUwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 16:52:44 -0400
In-Reply-To: <20090608.142927.122160930.davem@davemloft.net> (David Miller's
	message of "Mon, 08 Jun 2009 14:29:27 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > Maybe we need a different approach but (since we are at the point of
 > > talking about categorical fundamentally wrong statements) its
 > > fundamentally wrong if the IPoIB layer works differently from a regular
 > > Ethernet NIC. They should work in the same way.
 > 
 > This I agree on.  When a multicast group is joined, the IPoIB layer
 > should block in some way until the subscription is fully available
 > for use.

Not sure I understand.  What do you mean by block?  It is quite possible
that a single multicast group is waiting to be joined, while other
multicast groups and unicast traffic can be sent with no problem.  So
stopping the whole device queue and blocking everything doesn't seem
appropriate.

 - R.
