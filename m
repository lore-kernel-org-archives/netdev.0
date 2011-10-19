From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Wed, 19 Oct 2011 09:52:19 +0200
Message-ID: <1319010739.18562.6.camel@edumazet-laptop>
References: <20111018134537.GA17055@gondor.apana.org.au>
	 <20111019.030914.218521668377472155.davem@davemloft.net>
	 <1319008713.17914.8.camel@edumazet-laptop>
	 <20111019.033052.851679720607111734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36922 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab1JSHwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 03:52:39 -0400
In-Reply-To: <20111019.033052.851679720607111734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 19 octobre 2011 =C3=A0 03:30 -0400, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 19 Oct 2011 09:18:33 +0200
>=20
> > Seems fine (Maybe do the +15 in caller site ?), but we also have ot=
her
> > problematic cases, using alloc_skb() only...
>=20
> Ok, which ones operate over these problematic GRE tunnels?
>=20

I was more thinking of general idea to allow any device to change its
needed headroom.

=46or GRE tunnels, I dont think IPv6 fragmentation could be relevant,
but maybe IGMP could trigger a problem ?
