From: Nicolae Rosia <nicolae.rosia@certsign.ro>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with NET_IP_ALIGN
Date: Wed, 1 Jul 2015 17:29:42 +0300
Message-ID: <5593F956.4020300@certsign.ro>
References: <5592D105.7080006@certsign.ro>	 <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>	 <5593EB38.5050000@certsign.ro> <1435758289.4110.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.uti.ro ([91.220.13.110]:54869 "EHLO mx2.uti.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754450AbbGAOay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 10:30:54 -0400
In-Reply-To: <1435758289.4110.130.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2015 04:44 PM, Eric Dumazet wrote:
> I really doubt this adapter can process millions of packets per second ?
I was suggesting this since I was taking into consideration the comment 
from skbuff.c, "we can save several CPU cycles by avoiding having to 
disable and re-enable IRQs."
Is there a downside to this?

>
> I would rather enable GRO, it would be more useful.
I had no idea what GRO is, so I have read about it [0] and looked at a 
couple of drivers which use it. They all seem to
replace netif_receive_skb with napi_gro_receive and when there are no 
more packets in napi_pool they call napi_gro_flush.
Is it that simple?

Regards

[0] https://lwn.net/Articles/358910/
