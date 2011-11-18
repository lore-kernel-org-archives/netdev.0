From: David Miller <davem@davemloft.net>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Fri, 18 Nov 2011 13:04:29 -0500 (EST)
Message-ID: <20111118.130429.440180652561962303.davem@davemloft.net>
References: <20111118150512.5f66f7d2@asterix.rh>
	<1321636073.3277.38.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111118152142.717324b1@asterix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, famzah@icdsoft.com, netdev@vger.kernel.org,
	segoon@openwall.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab1KRSEw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 13:04:52 -0500
In-Reply-To: <20111118152142.717324b1@asterix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Flavio Leitner <fbl@redhat.com>
Date: Fri, 18 Nov 2011 15:21:42 -0200

> On Fri, 18 Nov 2011 18:07:53 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Le vendredi 18 novembre 2011 =E0 15:05 -0200, Flavio Leitner a =E9cr=
it :
>>=20
>> > Sorry, I meant that we are trying to avoid doing this:
>> > +			hash =3D rt_hash(daddr, skeys[s],
>> > ikeys[i],rt_genid(net)); +
>> > +			rthp =3D &rt_hash_table[hash].chain;
>> > +
>> > +			while ((rt =3D rcu_dereference(*rthp)) !=3D
>> > NULL) {
>> > +				rthp =3D &rt->dst.rt_next;
>>=20
>> Sure, but this is still needed right now.
>=20
> Yes, David will not be happy, unfortunately :)

He better be happy that someone is fixing all the bugs he added.
