From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 54/72] au1000_eth/mipsnet/tc35815: Move the MIPS drivers
Date: Sat, 25 Jun 2011 11:11:21 -0700
Message-ID: <1309025482.2454.90.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-55-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110625161353.GA20976@linux-mips.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-BqP0rTRzPe22vc5yVcBs"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Herbert Valerio Riedel <hvr@gnu.org>,
	MontaVista Software <source@mvista.com>,
	Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>,
	"James E.J. Bottomley" <jejb@parisc-linux.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	Sam Creasey <sammy@sammy.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	"linux-m68k@vger.kernel.org" <linux-m68k@vger.kernel.org>
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20110625161353.GA20976@linux-mips.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BqP0rTRzPe22vc5yVcBs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-06-25 at 09:13 -0700, Ralf Baechle wrote:
> On Sat, Jun 25, 2011 at 06:59:05AM -0700, Jeff Kirsher wrote:
>=20
> > Move the MIPS drivers into drivers/net/ethernet/mips/ and
> > make the necessary Kconfig and Makefile changes.
>=20
> NAck.
>=20
> sni_82596.c is a driver for the same chip but used in particular
> Siemens-
> Nixdorf systems.  Lasi_82596 is an Intel NIC being used in PARISC
> systems.
> Not a good reason th throw PA-RISC drivers into the same directory
> after
> all PA-RISC has no relation to MIPS at all.  So maybe they should go
> into
> drivers/net/ethernet/i82596 or drivers/net/ethernet/intel.  And
> wherever
> they go, both drivers #include lib82596.c which your patch did not
> move
> around.=20

My bad, I had grouped these drivers because they both used lib82596.c
and had thought I had moved that file as well.

--=-BqP0rTRzPe22vc5yVcBs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOBiTJAAoJECTsCADr/EWUUicH/iWVNtJdmOkrW7NNOdzV83ao
xowwQBCpvdAk9TrM5JbJRYHQftSHry4viHyMfO+RDC0VT8d1LGlgqHCJ3Y+1oQob
ibIG8uUGdSX1XdF3/LWdDXkLNSfsboV5wEnlYMW5zY0Wp3ETXdO4SN5Vp5O37EVl
YnUfkUR64dEot+8t5tKqAdjfXLcDZIex02lzfjtpDub5TAqoEGBNjAY1vTSakDBt
9ZlEluDAKJ1HU6+a9DcpW1r/BBCaFsQVOcRqOxi/mStbsCkvIajlj4qIbJP0U7ng
741GoMqR31oZkR5nqcqvGcJm8/WZEATj8y4Zk/+CTzamkTSN5i/hUsR2TuTaTe0=
=+nyO
-----END PGP SIGNATURE-----

--=-BqP0rTRzPe22vc5yVcBs--
