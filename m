From: Harald Welte <laforge@gnumonks.org>
Subject: Re: WCONF, netlink based WE replacement.
Date: Fri, 20 Jan 2006 09:48:29 +0100
Message-ID: <20060120084829.GW4603@sunbeam.de.gnumonks.org>
References: <200601121824.02892.mbuesch@freenet.de> <20060113131503.GA379@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Rnz0oC2K6vQ5doJs"
Cc: Michael Buesch <mbuesch@freenet.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750756AbWATIsg@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060113131503.GA379@postel.suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Rnz0oC2K6vQ5doJs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 13, 2006 at 02:15:03PM +0100, Thomas Graf wrote:
> * Michael Buesch <mbuesch@freenet.de> 2006-01-12 18:24
> > This is an attempt to rewrite the Wireless Extensions
> > userspace API, using netlink sockets.
> > There should also be a notification API, to inform
> > userspace for changes (config changes, state changes, etc).
> > It is not implemented, yet.
>=20
> I'll only comment on the netlink bits and leave the rest to
> others. I'd highly recommend the use of attributes instead
> of fixed message structures to allow the interface to be
> flexible to extensions while staying binary compatible.

I can only second Thomas' suggestion.  The power and flexibility of the
use of netlink is only really unveiled if you use attributes.   This way
you can easily extend your data structures later on without breaking
compatibility, etc.

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--Rnz0oC2K6vQ5doJs
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD0KPdXaXGVTD0i/8RAg8uAJ93BdIP+yQrQ6U6SIHOUnmsKOEhLgCfc3/D
AT328qAVmZtfuzjG2ZeYMB8=
=Hrag
-----END PGP SIGNATURE-----

--Rnz0oC2K6vQ5doJs--
