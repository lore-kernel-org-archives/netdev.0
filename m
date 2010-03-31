From: Glen Turner <gdt@gdt.id.au>
Subject: Re: UDP path MTU discovery
Date: Thu, 01 Apr 2010 10:12:03 +1030
Message-ID: <1270078923.2389.31.camel@ilion>
References: <1269561751.2891.8.camel@ilion> <4BAC0577.7070803@hp.com>
	 <20100325.202636.149498207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:36026 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754322Ab0CaXkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 19:40:42 -0400
In-Reply-To: <20100325.202636.149498207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-03-25 at 20:26 -0700, David Miller wrote:
> We already provide this information.
> 
> The socket ends up with EMSGSIZE in it's error queue, so the next time
> the application does I/O it sees that error immediately from the
> read/write call and thus knows that path MTU arrived.

Thanks David.

Does select() return from its blocking so the application can make
use of this indication immediately, rather than after the
application's exponentially-increasing wait?

Is an incoming ICMP the only cause of EMSGSIZE?  That is, can an
application safely retransmit immediately?

-- 
 Glen Turner
 www.gdt.id.au/~gdt

