From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Thu, 9 Jan 2014 20:46:33 +0000
Message-ID: <8566589F-17E2-47D4-AD38-1D42C6851642@intel.com>
References: <2C8FA848-3185-43BA-BDD7-955B0C7DD835@intel.com>
 <20140109.143923.437905458430188006.davem@davemloft.net>
 <25B12960-1709-4E96-A278-9DBF9009C0F5@intel.com>
 <20140109.151957.1618381015670153898.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_96D96603-74D4-4310-8A89-91CF6F0D6EC0";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32083 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbaAIUqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 15:46:35 -0500
In-Reply-To: <20140109.151957.1618381015670153898.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_96D96603-74D4-4310-8A89-91CF6F0D6EC0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Jan 9, 2014, at 12:19 PM, David Miller <davem@davemloft.net> wrote:

> From: "Rustad, Mark D" <mark.d.rustad@intel.com>
> Date: Thu, 9 Jan 2014 20:14:51 +0000

I'm sorry you dropped my entire procedural argument for not combining =
the changing of the case with the implementation of the static inlines. =
That really was and is important! I'm not opposed to changing the case. =
My concern is for procedurally when and how it gets done.

>> Obviously I could do it here, but I *really* think it is
>> procedurally a really bad idea to change the case as part of a
>> functional change. I thought I was doing a favor my at least making
>> them inlines, but prehaps not.
>=20
> It is never a good idea to allow functions to have all caps
> names and vice versa.  Please don't use "difficulty" as a reason
> to violate this.
>=20
> Doing things right is sometimes hard, I'm sorry to inform you :)

It is just that sometimes things take multiple steps. This was just one =
step. I'm sorry that I may have not made that clear enough. Doing the =
work is absolutely not the problem, managing the process so everyone can =
continue working is a concern.

>> Anyone want to take on changing the upper case static inlines in
>> mcf8390, 7990, benet, ns83820, s2io, vxge, iwlwifi, ath9k, wil6210,
>> mwifiex, and rtlwifi? And those are just under drivers/net.
>=20
> Sorry the "crap exists elsewhere, therefore I can make crap too"
> argument never holds any water.
>=20
> Just because crap exists elsewhere, doesn't mean you should duplicate =
it.

I'm sorry that the presence misled me into thinking that it was =
acceptable at least in a transitional phase.

I think I have found a way to address the barrier issue. I will add =
upper case macros that call the lower case inlines, so for a time both =
forms may exist, and then have a patch that will update the call sites, =
and then a patch to remove the macros.

Is that acceptable?

If only one person were working in this area and everything were serial, =
it would be much easier to manage this kind of change. When that is not =
the case, it is better for things to happen in separate steps.

--=20
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_96D96603-74D4-4310-8A89-91CF6F0D6EC0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBAgAGBQJSzwqmAAoJEDwO/+eO4+5ukfEP/1BIqIfR1HKmuygj6v1AogK9
+ZO9lxH4UGlCxJ4IsFwE9nJhDLud1KwT8ljjln2dkFz72X/9q3zDQfZ9vzgKkzGM
CBvcGbgYhoRg8YW8btv3SLKGKIOwyYYK7Zsa+LosQdlKq6l+Soyopdmvkeu4iUL+
NxQ5yOa7Jtj5xJYeS+tPxJf67GLmdoSG8HiIltUHDq1sMIU7TqBjpYxeICErHezR
ZZihAhZ0y7+p5UecWKNcIqDXtCvA9329oOrmcp8h0UKBKKLyIqAZHGrR4s2Eu+8U
i05PagIdwEICXsMh9GMI4s2ltUEEPQN71a5hD2CvpyyQWjcSxloMrwWlONd/3IE4
GDECHAIJkfAzKGncnkjVESqBtD/jyV43sfE92mxDB+cL5OLK1Nwm7Vp4G0baSmlP
6y9j/NqDIQevpFlAy4sA1yxjLOPEPUD44pxRno1yB9vyY267nsslnF2p/TgGrpYK
PKeyvBTb8JcVokkY02sNA4EhrJHNXuwsz+N7bBAL1Y+pZsUVOoRjTl4Pixy27YfR
BpeYsvM38Cp9P3viqDsF5CMMrBgh4KkJnLJwk5cv00i4I1NApDo17Ka8PD+a3z4n
2cJCgBKw2QMT0uSH241eKfDOfJ+XY0yrgn+vQb1KOB1bjH5ANbxhGhCMoSEE+YzL
4I5JycDwT8LjW2p1hHbj
=upf0
-----END PGP SIGNATURE-----

--Apple-Mail=_96D96603-74D4-4310-8A89-91CF6F0D6EC0--
