From: David Miller <davem@davemloft.net>
Subject: Re: UDP path MTU discovery
Date: Thu, 25 Mar 2010 20:24:24 -0700 (PDT)
Message-ID: <20100325.202424.201654947.davem@davemloft.net>
References: <1269561751.2891.8.camel@ilion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gdt@gdt.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40338
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753729Ab0CZDYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 23:24:07 -0400
In-Reply-To: <1269561751.2891.8.camel@ilion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Glen Turner <gdt@gdt.id.au>
Date: Fri, 26 Mar 2010 10:32:31 +1030

> This differs from TCP, where it is the kernel -- and not
> the application -- which organises retransmission. On
> receiving a ICMP Fragmentation Needed the kernel can
> immediately re-probe the path MTU wiht no waiting for
> an exponential timer to expire.

So the argument is, the kernel TCP does retransmission smart,
userspace UDP apps do it stupidly, so let's turn off the feature
instead of fixing userspace.

Right?

Sorry, fix this correctly in the user apps.  Putting the
blame on UDP path MTU discovery is placing it in the
wrong spot.

