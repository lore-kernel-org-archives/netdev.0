From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely when
 possible - bad side effect?
Date: Thu, 23 Jan 2014 11:47:33 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1401231056530.2682@ja.home.ssi.bg>
References: <52DCF1440200005D000477FD@gwia2.atlnz.lc> <alpine.LFD.2.11.1401222222010.1855@ja.home.ssi.bg> <20140123020224.GG7269@order.stressinduktion.org> <20140122.185305.1125981867482223830.davem@davemloft.net>
 <20140123030329.GI7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	gregory.hoggarth@alliedtelesis.co.nz, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:40676 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751792AbaAWJsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 04:48:36 -0500
In-Reply-To: <20140123030329.GI7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 23 Jan 2014, Hannes Frederic Sowa wrote:

> E.g. we register all local registered broadcast addresses in a structure
> like inet_addr_lst so we only need to check if the packet would leave
> this host with a broadcast hardware address. If the packet is forwarded
> the router must do the same check as only it knows the local broadcast
> addresses. I hope this is correct. ;)

	Now when we can override the local table with ip
rules or to prepend route in local table, we can not be
sure that the broadcast routes are returned in all cases,
users can add unicast routes for such addresses.

	I don't remember for useful case where one may need to
override broadcast routes but adding such exceptions looks
risky.

Regards

--
Julian Anastasov <ja@ssi.bg>
