From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Mon, 9 Aug 2004 15:29:30 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16837.1092058170@www25.gmx.net>
References: <4.3.2.7.2.20040807232436.00d6da60@pop.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Fernando Gont <fernando@gont.com.ar>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> At 11:34 05/08/2004 -0700, YOSHIFUJI Hideaki wrote:
>=20
> > > Now, on Linux, at this point, the second instance of the
> > > server fails with EADDRINUSE, even though it did use
> > > SO_REUSEADDR.  On FreeBSD 5.1, the second server instance
> > > does successfully bind.
> >
> >This behavior is intended.
> >First socket is REQUIRED to set SO_REUSEADDR
> >I hate BSD's behavior because it is asynmetry.
> >(Both sockets are required to agree on "REUSEADDR.")
>=20
> Not sure what you mean by "asymetry".

Ferando,

By asymmetry, I understand Hideaki to mean that BSD requires=20
SO_REUSEADDR in the second server bind(), but not the first.
the Linux philosophy then appears to be symmetry: both server
instances must agree that the socket port is reusable (i.e.,=20
both must set SO_REUSEADDR).

Cheers,

Michael

--=20
Michael Kerrisk
mtk-lists@gmx.net

NEU: WLAN-Router f=FCr 0,- EUR* - auch f=FCr DSL-Wechsler!
GMX DSL =3D superg=FCnstig & kabellos http://www.gmx.net/de/go/dsl
