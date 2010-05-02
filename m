From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Sun, 2 May 2010 17:46:49 +0200
Message-ID: <20100502154649.GA18063@gargoyle.fritz.box>
References: <20100429182347.GA8512@gargoyle.fritz.box> <1272568347.2209.11.camel@edumazet-laptop> <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net> <20100501110000.GB9434@gargoyle.fritz.box> <1272783366.2173.13.camel@edumazet-laptop> <20100502092020.GA9655@gargoyle.fritz.box> <1272797690.2173.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:37282 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755370Ab0EBPoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 11:44:21 -0400
Content-Disposition: inline
In-Reply-To: <1272797690.2173.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In this test, all 16 queues of one BCM57711E NIC (1Gb link) delivers
>  packets at about 1.300.000 pps to 16 cpus (one cpu per queue) and these
> packets are then redistributed by RPS to same 16 cpus, generating about
> 650.000 IPI per second.

BTW if rps was SMT aware it could avoid a lot of the IPIs in the first place.

-Andi

