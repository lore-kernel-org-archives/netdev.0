From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v3] gro: __napi_gro_receive() optimizations
Date: Fri, 27 Aug 2010 06:43:44 +0200
Message-ID: <1282884224.2501.33.camel@edumazet-laptop>
References: <20100825.135726.189708768.davem@davemloft.net>
	 <1282770911.2681.205.camel@edumazet-laptop>
	 <1282883713.2501.29.camel@edumazet-laptop>
	 <20100826.213816.112615295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54399 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab0H0Enu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:43:50 -0400
Received: by wyb35 with SMTP id 35so3061145wyb.19
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 21:43:49 -0700 (PDT)
In-Reply-To: <20100826.213816.112615295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 21:38 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 27 Aug 2010 06:35:13 +0200
>=20
> > +	fold |=3D *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);
>=20
> Shouldn't these be "+ 8" instead of "+ 6"?

Not really, we want to compare 14 bytes, not 16

So we have (sizeof(long) + sizeof(long)) - intersection

I guess I should comment this :)


