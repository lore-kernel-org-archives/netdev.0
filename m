From: Felix Palmen <fmp@palmen.homeip.net>
Subject: Re: Fw: unregister_netdevice(): negative refcnt, suggest patch against 2.6.11
Date: Mon, 11 Apr 2005 04:30:38 +0200
Message-ID: <20050411023038.GB13829@palmen.homeip.net>
References: <20050410034446.39e3025e.akpm@osdl.org> <20050410212727.GA13829@palmen.homeip.net> <20050410215050.GJ26731@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fba/0zbH8Xs+Fj9o"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050410215050.GJ26731@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Fba/0zbH8Xs+Fj9o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hallo Thomas,

* Thomas Graf <tgraf@suug.ch> [20050410 23:50]:
> Is it always 256? Do you have any appletalk routes configured?
> If so, is the 256 dependand on the number of routes?

That could really be the case:

- In my test with vanilla 2.6.11.7, there was no other appletalk
  station on the net -> refcnt was -256
- On my working system, I use a single route and get refcnt =3D -1
- When I first tried appletalk without configuring anything but the
  interface and PearPC with Mac OS X runnning on the other side, refcnt
  was -2

I'll try to double-check that tomorrow.

Greets, Felix

--=20
 | /"\   ASCII Ribbon   | Felix M. Palmen (Zirias)    http://zirias.ath.cx/=
 |
 | \ / Campaign Against | fmp@palmen.homeip.net      encrypted mail welcome=
 |
 |  X    HTML In Mail   | PGP key: http://zirias.ath.cx/pub.txt            =
 |
 | / \     And News     | ED9B 62D0 BE39 32F9 2488 5D0C 8177 9D80 5ECF F683=
 |

--Fba/0zbH8Xs+Fj9o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iQCVAwUBQlnhTgSq+3gxG9cNAQKVyQP9FSOgwHSky9rGx8WLFbya25ZBHqJZMQ4H
whyBqfhCOkA1YG3CvHcDqzqcQMz0zHa7PaZWe8GqiXD4ONIqLzQlvDWMfwuAnuV+
pX/LwVdYjIUf3BQWX6/JUFUROpmBTQkeUW9f2Hline8tZbx8G4OjkYf2DCwHlel9
KvGFLNyF3Kk=
=Oz45
-----END PGP SIGNATURE-----

--Fba/0zbH8Xs+Fj9o--
