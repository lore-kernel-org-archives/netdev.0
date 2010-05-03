From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 03 May 2010 16:15:31 -0400
Message-ID: <1272917731.3926.12.camel@bigi>
References: <20100429214144.GA10663@gargoyle.fritz.box>
	 <20100430.163857.180417789.davem@davemloft.net>
	 <20100501110000.GB9434@gargoyle.fritz.box>
	 <1272783366.2173.13.camel@edumazet-laptop>
	 <20100502092020.GA9655@gargoyle.fritz.box>
	 <1272797690.2173.26.camel@edumazet-laptop>
	 <20100502154649.GA18063@gargoyle.fritz.box>
	 <1272818131.2173.127.camel@edumazet-laptop>
	 <20100502212550.GA2673@gargoyle.fritz.box>
	 <1272836755.2173.153.camel@edumazet-laptop>
	 <20100502215450.GC2673@gargoyle.fritz.box>
	 <1272838104.2173.166.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	lenb@kernel.org, arjan@infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:52840 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756535Ab0ECUPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:15:37 -0400
Received: by pzk42 with SMTP id 42so347077pzk.4
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 13:15:36 -0700 (PDT)
In-Reply-To: <1272838104.2173.166.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-03 at 00:08 +0200, Eric Dumazet wrote:

> 
> Test I did this week with Jamal.
> 
> We first set a "ee" rps mask, because all NIC interrupts were handled by
> CPU0, and Jamal thought like you, that not using cpu4 would give better
> performance.
> 
> But using "fe" mask gave me a bonus, from ~700.000 pps to ~800.000 pps
> 

I am seeing the opposite with my machine (Nehalem):
with ee i get 99.4% and fe i get 94.2% whereas non-rps
is about 98.1%.


cheers,
jamal

PS:- sorry dont have time to collect a lot more data - tommorow i could
do more.


