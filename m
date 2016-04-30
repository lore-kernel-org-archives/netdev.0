From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?Q?don=E2=80=99t?= modify
 ip_summed; doing so treats packets with bad checksums as good.
Date: Sat, 30 Apr 2016 20:33:01 +0200
Message-ID: <1462041181.17662.3.camel@decadent.org.uk>
References: <lsq.1461711744.699003961@decadent.org.uk>
	 <5720E1F0.9010203@candelatech.com>
	 <1461780469.5102.0.camel@decadent.org.uk>
	 <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
	 <572155F4.10405@candelatech.com>
	 <20160428102953.GA7656@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MDk0dTSWxzYASKoxCrDC"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	xiyou.wangcong@gmail.com
To: Sabrina Dubroca <sd@queasysnail.net>,
	Ben Greear <greearb@candelatech.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20160428102953.GA7656@bistromath.localdomain>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MDk0dTSWxzYASKoxCrDC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-28 at 12:29 +0200, Sabrina Dubroca wrote:
> Hello,
>=20
> 2016-04-27, 17:14:44 -0700, Ben Greear wrote:
> >=20
> > On 04/27/2016 05:00 PM, Hannes Frederic Sowa wrote:
> > >=20
> > > Hi Ben,
> > >=20
> > > On Wed, Apr 27, 2016, at 20:07, Ben Hutchings wrote:
> > > >=20
> > > > On Wed, 2016-04-27 at 08:59 -0700, Ben Greear wrote:
> > > > >=20
> > > > > On 04/26/2016 04:02 PM, Ben Hutchings wrote:
> > > > > >=20
> > > > > >=20
> > > > > > 3.2.80-rc1 review patch.=C2=A0=C2=A0If anyone has any objection=
s, please let me know.
> > > > > I would be careful about this.=C2=A0=C2=A0It causes regressions w=
hen sending
> > > > > PACKET_SOCKET buffers from user-space to veth devices.
> > > > >=20
> > > > > There was a proposed upstream fix for the regression, but it has =
not gone
> > > > > into the tree as far as I know.
> > > > >=20
> > > > > http://www.spinics.net/lists/netdev/msg370436.html
> > > > [...]
> > > >=20
> > > > OK, I'll drop this for now.
> > > The fall out from not having this patch is in my opinion a bigger
> > > fallout than not having this patch. This patch fixes silent data
> > > corruption vs. the problem Ben Greear is talking about, which might n=
ot
> > > be that a common usage.
> > >=20
> > > What do others think?
> > >=20
> > > Bye,
> > > Hannes
> > >=20
> > This patch from Cong Wang seems to fix the regression for me, I think i=
t should be added and
> > tested in the main tree, and then apply them to stable as a pair.
> >=20
> > http://dmz2.candelatech.com/?p=3Dlinux-4.4.dev.y/.git;a=3Dcommitdiff;h=
=3D8153e983c0e5eba1aafe1fc296248ed2a553f1ac;hp=3D454b07405d694dad52e7f41af5=
816eed0190da8a
> Actually, no, this is not really a regression.
[...]

It really is. =C2=A0Even though the old behaviour was a bug (raw packets
should not be changed), if there are real applications that depend on
that then we have to keep those applications working somehow.

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.
--=-MDk0dTSWxzYASKoxCrDC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXJPpdAAoJEOe/yOyVhhEJZj0QAIGFkdLIWy4oaEWWz/7du5CF
7ZuFgfNMS9r0d4MlcNf4YKipop2gVNjzyXdUml5C1WuSRc+oU+LLteRb/PwiH4Us
Zo6TfxcNocTXECYUdOZDuEjSpgMg+/8mup4qsMb0LwvMsHjVQEYiiJJbw8IiT/zd
OWVW152CfDrQafYzWDvhmk8Wg5QOe/gtAhiY8xuxtg97nNb9Lfnkn8+SSix/XVdF
Ge+LbNxS8X15oVhC18OoQ2Z50UDwxAgxZGQgfhJNQNBrnJ3MXY2dMxuysBzZF0+c
UvYDM0SvQrL6NnTlVrJa8/swEuF+axarBzjl6JN8Nqn8EnEzRVLcHUHPzcS0wFrY
SN0LFSZdA/YJ7BQSHxHeM73jRZlel+ugVcmq2tieObSdYoOxqMEb9vyVMcT63W2j
KORPB5sMv1+8QZHlRUh1dnce9jlgPVZrDMk2XrQ5fcL8mVhEO/pSEoc+kZ0OlPzu
EAqGpjqZJDwviiO8HyS4f5r/qx0y+dtlzDFJGUytHzu8Om1S4LiiZlfjo5hJLZWI
3oHM7P/f6l7/Z7ck1UnlERRkASRiO41gDdvy4KAUNo3ktnCeuuZg46LFd0Hb4CFV
yk3muv2ZZX2w3tzfivJJYRovGJw0iXgNU0hou6j3NPcke6T1wvIxM2+fTA3cdsos
5OK3TMGB0GAamr3BulNV
=2MF9
-----END PGP SIGNATURE-----

--=-MDk0dTSWxzYASKoxCrDC--
