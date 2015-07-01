From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: macb: replace literal constant with
 NET_IP_ALIGN
Date: Wed, 01 Jul 2015 15:44:49 +0200
Message-ID: <1435758289.4110.130.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5592D105.7080006@certsign.ro>
	 <1435748191.4110.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5593EB38.5050000@certsign.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: Nicolae Rosia <nicolae.rosia@certsign.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37122 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbbGANoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 09:44:54 -0400
Received: by wicgi11 with SMTP id gi11so45990013wic.0
        for <netdev@vger.kernel.org>; Wed, 01 Jul 2015 06:44:52 -0700 (PDT)
In-Reply-To: <5593EB38.5050000@certsign.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-01 at 16:29 +0300, Nicolae Rosia wrote:
> On 07/01/2015 01:56 PM, Eric Dumazet wrote:
> > Then please use netdev_alloc_skb_ip_align(), so that you get rid of
> > skb_reserve()
> Thank you for the suggestion.
> I can do that.
> A related question, should I also replace netdev_alloc with 
> napi_alloc_skb in places where I have a napi struct?

I really doubt this adapter can process millions of packets per second ?

I would rather enable GRO, it would be more useful.
