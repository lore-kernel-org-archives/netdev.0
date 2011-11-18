From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Fri, 18 Nov 2011 15:21:42 -0200
Message-ID: <20111118152142.717324b1@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
	<20111116223330.08de9e52@asterix.rh>
	<4EC4C160.6010804@icdsoft.com>
	<20111117111145.252924f5@asterix.rh>
	<1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117133724.59684d28@asterix.rh>
	<1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117144038.61b0525b@asterix.rh>
	<1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117150145.25e01a75@asterix.rh>
	<1321550302.2751.81.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321551536.2751.87.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321632128.3277.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111118143016.01e24b37@asterix.rh>
	<1321634046.3277.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111118150512.5f66f7d2@asterix.rh>
	<1321636073.3277.38.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758061Ab1KRRWA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 12:22:00 -0500
In-Reply-To: <1321636073.3277.38.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Nov 2011 18:07:53 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 18 novembre 2011 =C3=A0 15:05 -0200, Flavio Leitner a =C3=
=A9crit :
>=20
> > Sorry, I meant that we are trying to avoid doing this:
> > +			hash =3D rt_hash(daddr, skeys[s],
> > ikeys[i],rt_genid(net)); +
> > +			rthp =3D &rt_hash_table[hash].chain;
> > +
> > +			while ((rt =3D rcu_dereference(*rthp)) !=3D
> > NULL) {
> > +				rthp =3D &rt->dst.rt_next;
>=20
> Sure, but this is still needed right now.

Yes, David will not be happy, unfortunately :)

> Once route cache is removed, this loop wont exist anymore ;)

That's the problem, we need to get rid of it first. :)

fbl
