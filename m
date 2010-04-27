From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Tue, 27 Apr 2010 15:10:05 -0700 (PDT)
Message-ID: <20100427.151005.133889860.davem@davemloft.net>
References: <1272271271.2346.16.camel@edumazet-laptop>
	<20100427.145904.67907652.davem@davemloft.net>
	<1272406126.2343.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756817Ab0D0WJ7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 18:09:59 -0400
In-Reply-To: <1272406126.2343.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Apr 2010 00:08:46 +0200

> Le mardi 27 avril 2010 =E0 14:59 -0700, David Miller a =E9crit :
>> net: Make RFS socket operations not be inet specific.
>>=20
>> Idea from Eric Dumazet.
>>=20
>> As for placement inside of struct sock, I tried to choose a place
>> that otherwise has a 32-bit hole on 64-bit systems.
>>=20
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I tested same patch today (plus the skb->rxhash =3D sk->sk_rxhash) an=
d got
> a very small speedup on my Nehalem machine, where get_rps_cpus() was
> using 1 % of cpu, now 0.25 %, on a tbench.

Great, I've added your ACK.

Thanks!
