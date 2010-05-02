From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Sun, 2 May 2010 11:20:20 +0200
Message-ID: <20100502092020.GA9655@gargoyle.fritz.box>
References: <20100429182347.GA8512@gargoyle.fritz.box> <1272568347.2209.11.camel@edumazet-laptop> <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net> <20100501110000.GB9434@gargoyle.fritz.box> <1272783366.2173.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53150 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107Ab0EBJRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 05:17:52 -0400
Content-Disposition: inline
In-Reply-To: <1272783366.2173.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I tried it on the right spot (since my bench was only doing recvmsg()
> calls, I had to patch wait_for_packet() in net/core/datagram.c
> 
> udp_recvmsg -> __skb_recv_datagram -> wait_for_packet ->
> schedule_timeout
> 
> Unfortunatly, using io_schedule_timeout() did not solve the problem.

Hmm, too bad. Weird.

> 
> Tell me if you need some traces or something.

I'll try to reproduce it and see what I can do.

-Andi

