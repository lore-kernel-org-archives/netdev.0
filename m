From: Nicolae Rosia <nicolae.rosia@certsign.ro>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with NET_IP_ALIGN
Date: Wed, 1 Jul 2015 16:29:28 +0300
Message-ID: <5593EB38.5050000@certsign.ro>
References: <5592D105.7080006@certsign.ro> <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.uti.ro ([91.220.13.110]:52991 "EHLO mx2.uti.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbbGANai (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 09:30:38 -0400
In-Reply-To: <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2015 01:56 PM, Eric Dumazet wrote:
> Then please use netdev_alloc_skb_ip_align(), so that you get rid of
> skb_reserve()
Thank you for the suggestion.
I can do that.
A related question, should I also replace netdev_alloc with 
napi_alloc_skb in places where I have a napi struct?
