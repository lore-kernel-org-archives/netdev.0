From: "Michael T Kerrisk" <mtk-lists@gmx.net>
Subject: Re: SO_REUSEADDR behavior different from BSD
Date: Fri, 6 Aug 2004 00:25:19 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20734.1091744719@www51.gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: ahu@ds9a.nl, netdev@oss.sgi.com, David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI.Hideaki/$B5HF#1QL@.sgi.com (B <yoshfuji@wide.ad.jp>)
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> In article <19686.1091723777@www48.gmx.net> (at Thu, 5 Aug 2004 18:36:1=
7
> +0200 (MEST)), "Michael T Kerrisk" <mtk-lists@gmx.net> says:
>=20
> > Now, on Linux, at this point, the second instance of the=20
> > server fails with EADDRINUSE, even though it did use=20
> > SO_REUSEADDR.  On FreeBSD 5.1, the second server instance=20
> > does successfully bind.
>=20
> This behavior is intended.
> First socket is REQUIRED to set SO_REUSEADDR
> I hate BSD's behavior because it is asynmetry.
> (Both sockets are required to agree on "REUSEADDR.")

Hideaki, David,

Thank you for the information / confirmation that this is intended
behavior.  I'll try to see that something on this point makes it=20
into the man pages.

Cheers,

Michael

--=20
Michael Kerrisk
mtk-lists@gmx.net

NEU: WLAN-Router f=FCr 0,- EUR* - auch f=FCr DSL-Wechsler!
GMX DSL =3D superg=FCnstig & kabellos http://www.gmx.net/de/go/dsl
