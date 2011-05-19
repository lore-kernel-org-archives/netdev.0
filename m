From: Felipe Balbi <balbi@ti.com>
Subject: Re: [RFC/PATCH 00/13] wl12xx re-factor
Date: Thu, 19 May 2011 17:06:53 +0300
Message-ID: <20110519140650.GQ13908@legolas.emea.dhcp.ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
 <1305809345.12586.1579.camel@cumari>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/neOAU127r7zg3jS"
Cc: Felipe Balbi <balbi@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305809345.12586.1579.camel@cumari>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--/neOAU127r7zg3jS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, May 19, 2011 at 03:49:05PM +0300, Luciano Coelho wrote:
> > this is the re-factor I was talking to you
> > about. Please have a look and give your
> > comments.
> >=20
> > It probably won't work as is, I compile
> > tested only, but it shows the idea.
>=20
> This looks very good! I think we should do something like this to avoid
> the code that is duplicated in the bus modules.
>=20
> But, as I already mentioned briefly on IRC, there is a problem with the
> way you changed the platform data structure, because it will break
> compat-wireless.  The actual memory and data that is used by the
> platform data is in the board components and not part of the wireless
> subsystem.  With compat-wireless, we need to make sure that new stuff
> works with older kernels.  In your patches you modify the platform data
> structure, so when we run an old kernel with new compat-wireless, things
> will break.
>=20
> We already found a similar bug due to a previous change in the platform
> data structure, so I don't want this to happen again.  So for now, I'll
> keep these patches aside, but as soon as we find a good solution, I'll
> definitely use your ideas here (or ask you to rebase :P).
>=20
> I'll probably apply some of the patches that are not related to the
> platform data change.  I'll respond to those specific patches
> separately.

ok good. I have stated my POV WRT compatibility layers for in-tree
drivers on a separate thread. In summary, I think those shouldn't exist
at all :-)

Just let me know if you need anything ;-)

--=20
balbi

--/neOAU127r7zg3jS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN1SP6AAoJEAv8Txj19kN1r7kH/i6inVclkYCLn3xVwohcwVYd
JWlFtmIG13HS+djkNWJxNp2nHnYKHAGFl46zbmLfYH4Hblsj6Myi+ftJTOqQTNoB
UZ7EqtamloGtNfqxHVEWWZE7YpEE9RtwMTqRo/w53WnmYxQ19J/mcyNewBu/bKf6
UQQtQYdR94/2M/XMyw8ciU5k5XYthoK2gGlKeBws0vc+RVVP+glOV67eI3LqQsYg
Mw+wauZj/26GdYl3ga93z8fZ1i8eMWqSpBHjTuizk81iAIYglISi115rBsTe3RSR
tIeZtYeqTQpgAHa0MbnkBWsdiSoHm+kGBZ9XCJWDcGb+blhSZq+b5d5Ann+0fYI=
=SvX+
-----END PGP SIGNATURE-----

--/neOAU127r7zg3jS--
