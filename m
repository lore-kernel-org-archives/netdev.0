From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: ip_gre headroom allocation
Date: Thu, 11 Jun 2009 13:17:14 +0300
Message-ID: <4A30D9AA.1020004@iki.fi>
References: <4A30BECA.8030205@iki.fi> <20090611.030922.91415233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:47308 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215AbZFKKRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 06:17:12 -0400
Received: by ewy6 with SMTP id 6so1864539ewy.37
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 03:17:13 -0700 (PDT)
In-Reply-To: <20090611.030922.91415233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Timo Ter=E4s <timo.teras@iki.fi>
> Date: Thu, 11 Jun 2009 11:22:34 +0300
>=20
>> I'm not entirely sure about this, but shouldn't we do something like
>> the below to make ip_gre allocation enough headroom for paths where
>> e.g. xfrm transformations take place (as a speed optimization)?
>=20
> This should be handled by the code one level up that allocates
> the SKB.
>=20
> And as routes get stacked, the MTUs and headroom values get adjusted
> up to the root.
>=20
> At least that's how it's supposed to work :-)

Ok, that makes sense. I was just wondering if there's any corner cases
were this would have helped.

> Otherwise we'd need a similar hack in ipip.c too.

I was under the impression that as we need to do the route lookup anywa=
y
we could take advantage of the information available from there fully.

But yes, your explanation makes perfect sense.

Thanks,
  Timo

