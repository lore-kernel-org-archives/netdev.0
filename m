From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Mon, 3 May 2010 00:06:42 +0200
Message-ID: <20100502220642.GD2673@gargoyle.fritz.box>
References: <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net> <20100501110000.GB9434@gargoyle.fritz.box> <1272783366.2173.13.camel@edumazet-laptop> <20100502092020.GA9655@gargoyle.fritz.box> <1272797690.2173.26.camel@edumazet-laptop> <20100502071324.1a95fdad@infradead.org> <1272810448.2173.31.camel@edumazet-laptop> <20100502105418.7abf83a7@infradead.org> <1272828143.2173.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36024 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab0EBWEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 18:04:11 -0400
Content-Disposition: inline
In-Reply-To: <1272828143.2173.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But a task blocked on disk IO is probably blocked for a small amount of
> time, while on network, it can be for a long time. I am not sure its the
> right metric.

I think it needs a dynamic timeout.

I agree the reference count as is will not work well for networking.

> 
> I was expecting something based on recent history.
> Say if we have 20.000 wakeups per second, most likely we should not
> enter C2/C3 states...

That's what the menu governour already does, it just doesn't work
in some cases :/

-Andi

