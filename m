From: Lorenzo =?ISO-8859-1?Q?Hern=E1ndez_?= =?ISO-8859-1?Q?Garc=EDa-Hierro?= <lorenzo@gnu.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 19:36:13 +0100
Message-ID: <1106937373.3864.10.camel@localhost.localdomain>
References: <1106932637.3778.92.camel@localhost.localdomain>
	 <1106935677.7776.29.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DiYfYfHaSOb0nEIQMp5W"
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        torvalds@osdl.org, netdev@oss.sgi.com, Chris Wright <chrisw@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1106935677.7776.29.camel@laptopd505.fenrus.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-DiYfYfHaSOb0nEIQMp5W
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

El vie, 28-01-2005 a las 19:07 +0100, Arjan van de Ven escribi=F3:
> On Fri, 2005-01-28 at 18:17 +0100, Lorenzo Hern=E1ndez Garc=EDa-Hierro
> wrote:
> > Hi,
> >=20
> > Attached you can find a split up patch ported from grSecurity [1], as
> > Linus commented that he wouldn't get a whole-sale patch, I was working
> > on it and also studying what features of grSecurity can be implemented
> > without a development or maintenance overhead, aka less-invasive
> > implementations.
>=20
>=20
> why did you make it a config option? This is the kind of thing that is
> either good or isn't... at which point you can get rid of a lot of, if
> not all the ugly ifdefs the patch adds.

I will remove the ifdef's, I've made it just from the usability POV,
users may want the standard "randomization" schema, dunno.
Anyway, I will remove those ifdef's and make it enabled-by-default.

> Also, why does it need to enhance the random driver this much, the
> random driver already has a facility to provide pseudorandom numbers
> good enough for networking use (eg the PRNG rekeys often enough with
> real entropy that brute forcing it shouldn't be possible).

I will also remove the pool sizes increasing diffs from the patch.

> If you can fix those 2 things the patch will look a lot cleaner and has
> a lot higher chance to be merged.

Sure, many thanks for pointing out that clearly.
It will take a few minutes and then re-send the patch.

Cheers,
--=20
Lorenzo Hern=E1ndez Garc=EDa-Hierro <lorenzo@gnu.org>=20
[1024D/6F2B2DEC] & [2048g/9AE91A22][http://tuxedo-es.org]

--=-DiYfYfHaSOb0nEIQMp5W
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Esta parte del mensaje =?ISO-8859-1?Q?est=E1?= firmada
	digitalmente

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBB+oYdDcEopW8rLewRAgDjAJ9fLotSjAya06xCoxQqjfgEFS1ErACg1OI3
fTIcghUC06DTIb10Tyg3YZ0=
=vmpI
-----END PGP SIGNATURE-----

--=-DiYfYfHaSOb0nEIQMp5W--
