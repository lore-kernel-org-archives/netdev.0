From: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
Subject: Re: Fw: hfsc and huge set of rules
Date: Wed, 4 Aug 2004 11:14:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804091402.GB30364@krezus.e-wro.net>
References: <20040729211844.61e8d328.davem@redhat.com> <410A2449.3020701@trash.net> <20040730110815.GA7812@krezus.e-wro.net> <410D2E30.2050104@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xXmbgvnjoT4axfJE"
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, devik@cdi.cz,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <410D2E30.2050104@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--xXmbgvnjoT4axfJE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 01, 2004 at 07:53:52PM +0200, Patrick McHardy wrote:
> I've done some profiles with your script (on an old kernel without
> the lockless loopback patch), qdisc_destroy takes up 89% of the time
> when destroying the qdiscs.
>=20
> These are the exact results:
>=20
> - execute the script on kernel using double-linked lists for=20
> dev->qdisc_list:
>=20
> time:
> real    0m51.804s
> user    0m2.286s
> sys     0m48.795s

The results are great ! Thanks ! I'am using hfsc with 2.4.x kernel so there=
 will
be no problem with lockless loopback patch ;] So could you please send me
a patch ?


--=20
Tomasz Paszkowski

--xXmbgvnjoT4axfJE
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFBEKjacNXOL98XeysRAsD+AJ9N8kuFRVVGPhwcmOX3zzoIc7PcBwCePN4Y
KtoRRqExgx+zRZrwtwcD51o=
=0LUN
-----END PGP SIGNATURE-----

--xXmbgvnjoT4axfJE--
