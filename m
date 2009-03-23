From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] Re: TCP/IP stack interpretation of
 acceptable packet
Date: Sun, 22 Mar 2009 21:50:33 -0700 (PDT)
Message-ID: <20090322.215033.192091282.davem@davemloft.net>
References: <2ff60cd60902241459q1de39054lb3dc5233f13b69c3@mail.gmail.com>
	<1237423493.32009.31.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mailinglists+netdev@oliverzheng.com, netdev@vger.kernel.org,
	andi@firstfloor.org
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751613AbZCWEuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:50:46 -0400
In-Reply-To: <1237423493.32009.31.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Thu, 19 Mar 2009 00:44:53 +0000

> [PATCH net-next-2.6] tcp: Discard segments that ack data not yet sent
> 
> Discard incoming packets whose ack field iincludes data not yet sent.
> This is consistent with RFC 793 Section 3.9.
> 
> Change tcp_ack() to distinguish between too-small and too-large ack
> field values.  Keep segments with too-large ack fields out of the fast
> path, and change slow path to discard them.
> 
> Reported-by:  Oliver Zheng <mailinglists+netdev@oliverzheng.com>
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

I've been mulling over this patch for more than a week :-)

Let's put this into net-next-2.6 and let it cook there for
a while.  It is possible I'll backport this into -stable
after some time.

Thanks!
