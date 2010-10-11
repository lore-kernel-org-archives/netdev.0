From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: speedup neigh_resolve_output()
Date: Mon, 11 Oct 2010 12:16:09 -0700 (PDT)
Message-ID: <20101011.121609.246536311.davem@davemloft.net>
References: <1286456008.2912.171.camel@edumazet-laptop>
	<1286484247.3745.91.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43519
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755847Ab0JKTPr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 15:15:47 -0400
In-Reply-To: <1286484247.3745.91.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Oct 2010 22:44:07 +0200

> Le jeudi 07 octobre 2010 =E0 14:53 +0200, Eric Dumazet a =E9crit :
>=20
>> Further improvements would need to use a seqlock instead of an rwloc=
k to
>> protect neigh->ha[], to not dirty neigh too often and remove two ato=
mic
>> ops.
>>=20
>=20
> I implemented this idea in following patch, on top on previous one.
>=20
> [PATCH net-next] neigh: speedup neigh_resolve_output()

So Eric do you think this is more efficient than the idea I
proposed, which is to "cmpxchg 'hh' and RCU"?

If you think this seqlock thing is faster or more desirable
for some reason, I'll add it.

Thanks!
