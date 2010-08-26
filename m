From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 11:03:54 +0200
Message-ID: <1282813434.2476.200.camel@edumazet-laptop>
References: <1282768431.2681.144.camel@edumazet-laptop>
	 <20100825.135726.189708768.davem@davemloft.net>
	 <1282770911.2681.205.camel@edumazet-laptop>
	 <20100826.005139.183034040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34926 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab0HZJD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 05:03:59 -0400
Received: by wyb35 with SMTP id 35so1928422wyb.19
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 02:03:57 -0700 (PDT)
In-Reply-To: <20100826.005139.183034040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 00:51 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 25 Aug 2010 23:15:11 +0200
>=20
> > Yes, we can inline it, this will speedup the non vlan case as well =
:)
>=20
> Agreed.
>=20
> But I believe you can find a better place to put __napi_gro_receive()
> than etherdevice.h, even though yes it does have a hard dependency on
> that thing. :-)
>=20

I tried but failed :(

Or move __napi_gro_receive() in a new header,
because etherdevice.h needs to include netdevice.h

(is_etherdev_addr(), dev_hw_addr_random())


