From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Mon, 29 Jun 2009 19:09:59 +0200
Message-ID: <20090629170959.GA2742@ami.dom.local>
References: <20090629083315.GA4712@ff.dom.local> <4A488EB8.4070602@itcare.pl> <20090629104703.GC4712@ff.dom.local> <4A48EACF.30903@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Robert Olsson <robert@robur.slu.se>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:48281 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbZF2RKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 13:10:23 -0400
Received: by bwz9 with SMTP id 9so3394092bwz.37
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 10:10:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A48EACF.30903@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 06:24:47PM +0200, Pawe=B3 Staszewski wrote:
> Jarek Poplawski pisze:
>> On Mon, Jun 29, 2009 at 11:51:52AM +0200, Pawe=B3 Staszewski wrote:
>>  =20
>>> I apply this patch
>>>
>>> fib_triestats in attached file :)
>>>    =20
>>
>> Great! But it would be nice to check if this (accidentally ;-) might
>> fix the previous problem, so I attach below the patch with "manual
>> RCU", which btw. (or even more important) should verify RCU use here=
=2E
>>
>>  =20
> After this patches all is OK now i don't see Fix inflate_threshold_ro=
ot.
> Even if i make "clear ip bgp * "
>
> Before this patches when i make clear ip bgp there was always info in=
 =20
> dmesg about "Fix inflate_threshold_root"
>
>
>> It should be applied on top of this last "Fix..., part3". And
>> again: it's quite probable it can fail, so with caution, no hurry
>> (it can wait for quiet time)...
>>
>>  =20
> After apply this last patch - traffic is not forwarded again :)
> i was fast and have only some fib_triestats in attached file before =20
> failover switch routers.
>
> This stats are from machine with this last patch that makes kernel to=
 =20
> stop forwarding

OK, I'll look at it again.

Thanks for testing!
Jarek P.
