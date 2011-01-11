From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 22:06:17 +0100
Message-ID: <1294779977.3447.3.camel@edumazet-laptop>
References: <1294764515-15356-1-git-send-email-stefani@seibold.net>
	 <1294765273.2927.65.camel@edumazet-laptop>
	 <1294779020.16410.2.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com,
	jj@chaosbits.net, daniel.baluta@gmail.com, jochen@jochen.org,
	hagen@jauu.net, torvalds@linux-foundation.org, pavel@ucw.cz
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294779020.16410.2.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 11 janvier 2011 =C3=A0 21:50 +0100, Stefani Seibold a =C3=A9cr=
it :
> Am Dienstag, den 11.01.2011, 18:01 +0100 schrieb Eric Dumazet:
> > Le mardi 11 janvier 2011 =C3=A0 17:48 +0100, stefani@seibold.net a =
=C3=A9crit :
> > > From: Stefani Seibold <stefani@seibold.net>
> > >=20
> > ...
> > > The implementation is clean and has absolut no side effects to th=
e network
> > > subsystems so i ask for merge it into linux, mm-tree or linux-nex=
t.
> > >=20
> > > The patch is against the current linux git tree
> > >=20
> > > - Stefani
> > >=20
> > > Signed-off-by: Stefani Seibold <stefani@seibold.net>
> > > ---
> > > =20
> >=20
> > Reading again UDPCP specs, I find it is IPv4/IPv6 agnostic
> >=20
> > You copied IPv4 UDP code, so this only handles IPv4...
> >=20
>=20
> Right, but currently there is no need for an IPV6 implementation, non=
 of
> our base station provide it and non of our mobile network customers u=
se
> it.
>=20
> If it will be required in the future it will be implemented.
>=20
>=20

All I wanted to point out is the implementation you did, using a copy o=
f
code instead of stacked layer, makes this ipv6 a whole rewrite.

Better understand know the implications, before code inclusion.

I understand your code satisfies your immediate needs (and companies
that paid this development), but we should make a step forward in code
reuse.
