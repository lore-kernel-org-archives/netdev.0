From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 02/72] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Sat, 09 Jul 2011 08:27:43 -0700
Message-ID: <1310225264.26989.32.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110628092212.37708ca7@bob.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-UutNWgiYassj6kNSh6zE"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Philip Blundell <philb@gnu.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	Donald Becker <becker@scyld.com>,
	Craig Southeren <craigs@ineluki.apana.org.au>,
	David Hinds <dahinds@users.sourceforge.net>
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27142 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754002Ab1GIP1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 11:27:45 -0400
In-Reply-To: <20110628092212.37708ca7@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-UutNWgiYassj6kNSh6zE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-06-28 at 01:22 -0700, Alan Cox wrote:
> On Sat, 25 Jun 2011 06:58:13 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>=20
> > Moves the 3Com drivers into drivers/net/ethernet/3com/ and the
> > necessary Kconfig and Makefile changes.
>=20
> This seems a bizarre way to carve stuff up.
>=20
> To start with several of the things you put in 3com are just branded
> items, or are boards using non 3com devices which are currently with
> the other drivers that do so, some even use shared midlayers that you
> move them away from.

When I first started the process of organizing drivers/net/ I thought it
made sense to group the 3Com drivers together, even though one of the
drivers (3c503) used the 8390 common code.  Looking back, it does make
sense to keep the 3c503 driver in drivers/net/ethernet/8390/ along with
the other 8390 drivers.

>=20
> You also pull stuff out of pcmcia which makes it harder to scan stuff
> grouped logically.

The logic behind this was to have all the Ethernet drivers in
drivers/net/ethernet/.  Since the drivers in drivers/net/pcmcia/ are not
sharing any special network common code or library, it did not seem to
make sense to me to keep them in drivers/net/pcmcia.  Eventually, there
would not be a drivers/net/pcmcia directory since all the drivers in
that directory would be moved into the appropriate
drivers/net/<technology>/ directory (i.e. ethernet, token-ring,fddi,
wireless, etc).  If there were a number of PCMCIA Ethernet drivers,
which all shared a common library or code, then it would make sense to
place them in drivers/net/ethernet/pcmcia/


> So this all seems a bit daft to me.
>=20
> Surely it would make sense to put all the Intel 825xx stuff together,
> all the 8390 stuff together and so on.
>=20
> Alan



--=-UutNWgiYassj6kNSh6zE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOGHNvAAoJECTsCADr/EWUxloH/3kSiDnTZD4b5ToKjQjQ/P5D
uHNAhdp2/52V/rWygruE9AzEwpkabiqOTlBRKI8WSBqmiDol6EdnXZAf9dGLZaGO
3PfLniaiKHc4OTwbHyQIjIsaFUyz9LOrAUPH7V6qvj8N5OyoYUygMAJJ0qb/3SCL
hXUiM315fkn+7BCgTlSzMfntHs1wCyKL0JRSmvaNpXf9xhl8/QInvEuv0l44ZnqQ
dUXOUnpjuP2pB00duKqm5gYFhwcCiXmPzCtbopbGWmg8PAjchyKlK4yIL8v6tn2d
xYalGM2MuS4k+k5eOF/dTgg20rwidhtJi6J61TQpL6n3ZEVfCIliVohh6w2+Y5w=
=dFoB
-----END PGP SIGNATURE-----

--=-UutNWgiYassj6kNSh6zE--

