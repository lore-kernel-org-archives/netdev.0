From: mcgrof@studorgs.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Prism54 2.6 kernel update
Date: Tue, 4 May 2004 16:41:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040504204139.GC18081@ruslug.rutgers.edu>
References: <5.0.2.1.2.20040429111349.00afb9c0@192.168.6.2> <4097DCC8.5070301@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1SQmhf2mF2YjsYvc"
Cc: Margit Schubert-While <msw@sim-basis.de>,
        Margit Schubert-While <margitsw@t-online.de>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4097DCC8.5070301@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--1SQmhf2mF2YjsYvc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 04, 2004 at 02:11:20PM -0400, Jeff Garzik wrote:
> Margit Schubert-While wrote:
> >2004-04-26      Margit Schubert-While <margitsw@t-online.de>
> >
> >        * islpci_mgt.h : Replace init_wds with a define.
> >        The compiler does not optimize it out (and also generates the
> >        field in the ro section of every module)
> >
> >        * prismcompat(24).h : Include linux/compiler.h
> >        Now we can play with the likely/unlikely macros
> >
> >        * islpci_eth.c, islpci_dev.c : Align skb->data unconditonally
> >        after allocation.  This would appear to improve RX rate.
> >        Do a little bit of likely/unlikely.
>=20
>=20
> You are violating a standard Linux development rule --
>=20
> You MUST send multiple patches, one change per patch.
>=20
> "One big patch" is only acceptable the first time, when the driver is=20
> initially merged.

Jeff,=20

we'll work on sending separate patches. Luckily I tagged things on our
cvs repository since the 2.6 merge <-> our tree matchup so this
shouldn't be that bad.

If I don't get to it, Margit will.=20

	Luis
--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--1SQmhf2mF2YjsYvc
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAmAADat1JN+IKUl4RAhYkAJ9m25h3iqGBZ1JiW0O7JdpGNHa8ygCeOG17
gwPlpHXTJmK3lJfR+D6U4EY=
=utG8
-----END PGP SIGNATURE-----

--1SQmhf2mF2YjsYvc--
