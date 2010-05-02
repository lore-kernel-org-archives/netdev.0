From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Sun, 2 May 2010 23:25:50 +0200
Message-ID: <20100502212550.GA2673@gargoyle.fritz.box>
References: <20100429182347.GA8512@gargoyle.fritz.box> <1272568347.2209.11.camel@edumazet-laptop> <20100429214144.GA10663@gargoyle.fritz.box> <20100430.163857.180417789.davem@davemloft.net> <20100501110000.GB9434@gargoyle.fritz.box> <1272783366.2173.13.camel@edumazet-laptop> <20100502092020.GA9655@gargoyle.fritz.box> <1272797690.2173.26.camel@edumazet-laptop> <20100502154649.GA18063@gargoyle.fritz.box> <1272818131.2173.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org, arjan@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59464 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755520Ab0EBVXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 17:23:23 -0400
Content-Disposition: inline
In-Reply-To: <1272818131.2173.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You mean we can wakeup a thread with something else than an IPI ?

It's pointless to send an IPI to your thread sibling for this. 
Everything it could do you can do yourself too with the same performance.

-Andi
