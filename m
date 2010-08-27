From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 22:01:48 -0700 (PDT)
Message-ID: <20100826.220148.183036083.davem@davemloft.net>
References: <1282883713.2501.29.camel@edumazet-laptop>
	<20100826.213816.112615295.davem@davemloft.net>
	<1282884224.2501.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753298Ab0H0FBd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Aug 2010 01:01:33 -0400
In-Reply-To: <1282884224.2501.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Aug 2010 06:43:44 +0200

> Le jeudi 26 ao=FBt 2010 =E0 21:38 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 27 Aug 2010 06:35:13 +0200
>>=20
>> > +	fold |=3D *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);
>>=20
>> Shouldn't these be "+ 8" instead of "+ 6"?
>=20
> Not really, we want to compare 14 bytes, not 16
>=20
> So we have (sizeof(long) + sizeof(long)) - intersection

I see.

> I guess I should comment this :)

Yes, that would help feeble minds like mine :-)  Repost with a comment
and I'll apply it, thanks!

