From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Check skb->rxhash in gro_receive
Date: Mon, 13 Jan 2014 13:24:31 -0800
Message-ID: <CA+mtBx_a0cnqXHFk3zRuQQnRNUqMet=N3h10HPgTGghyGoh=xA@mail.gmail.com>
References: <alpine.DEB.2.02.1401092051020.25554@tomh.mtv.corp.google.com>
	<1389332287.31367.88.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx_c=we-13b0Vyrim0=kArhx0OYY1P99HwUeuR2w87hRFw@mail.gmail.com>
	<20140113.115913.1269834557058575064.davem@davemloft.net>
	<1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:48782 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbaAMVYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 16:24:32 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so2088161ief.9
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 13:24:31 -0800 (PST)
In-Reply-To: <1389644256.31367.223.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 12:17 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-01-13 at 11:59 -0800, David Miller wrote:
>
>> It also doesn't jive well with Eric's recent patch to adjust the GRO
>> overflow strategy (600adc18eba823f9fd8ed5fec8b04f11dddf3884 ("net:
>> gro: change GRO overflow strategy"))
>>
>> :-)
>>
>> I sort of like Tom's idea to optimistically compare the hash, if we
>> do in fact have one already.
>>
>> Eric would the change be OK if Tom did it that way?
>> --
>
> Yes this is what I suggested, but it seems Tom had something different
> in mind.
>

I will add skb_get_hash_noeval

> I would rather not call flow dissector from GRO, especially considering
> nobody but Google uses RPS/RFS (otherwise CVE-2013-4348 would have been
> discovered much sooner)

Or maybe nobody uses IPIP. ;-)

>
>
>
