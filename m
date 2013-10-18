From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] xfrm: Don't queue retransmitted packets if the
 original is still on the host
Date: Fri, 18 Oct 2013 16:34:12 -0400 (EDT)
Message-ID: <20131018.163412.487683352492277510.davem@davemloft.net>
References: <20131016114246.GB7660@secunet.com>
	<20131018.161908.1422032342884472542.davem@davemloft.net>
	<1382127825.3284.37.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613Ab3JRUeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:34:14 -0400
In-Reply-To: <1382127825.3284.37.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Oct 2013 13:23:45 -0700

> On Fri, 2013-10-18 at 16:19 -0400, David Miller wrote:
>> From: Steffen Klassert <steffen.klassert@secunet.com>
>> Date: Wed, 16 Oct 2013 13:42:47 +0200
>> 
>> > It does not make sense to queue retransmitted packets if the
>> > original packet is still in some queue of this host. So add
>> > a check to xdst_queue_output() and drop the packet if the
>> > original packet is not yet sent.
>> > 
>> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> 
>> I have no problems with this, what about you Eric?
> 
> It looks fine to me.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Great, Steffen I assume you'll merge this in via your ipsec tree.
