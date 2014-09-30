From: Wolfram Sang <wsa@the-dreams.de>
Subject: Re: [PATCH v2 2/3] net: can: c_can: Add syscon/regmap RAMINIT
 mechanism
Date: Tue, 30 Sep 2014 17:25:50 +0200
Message-ID: <20140930152550.GR1325@katana>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com>
 <1410273070-22485-3-git-send-email-rogerq@ti.com>
 <20140930132650.GN1325@katana>
 <542AB137.30507@ti.com>
 <20140930135226.GO1325@katana>
 <542AB6E9.9000907@ti.com>
 <20140930141909.GP1325@katana>
 <542ABC90.7010900@pengutronix.de>
 <20140930144950.GQ1325@katana>
 <542AC5B2.9040406@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="soWJpSPh+l8Y6Fy7"
Cc: Roger Quadros <rogerq@ti.com>, wg@grandegger.com, tony@atomide.com,
	tglx@linutronix.de, mugunthanvnm@ti.com, george.cherian@ti.com,
	balbi@ti.com, nsekhar@ti.com, nm@ti.com,
	sergei.shtylyov@cogentembedded.com, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <542AC5B2.9040406@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--soWJpSPh+l8Y6Fy7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> Yes, but syscon_regmap_lookup_by_phandle() doesn't need any support for
> additional parameters. Have a look at:
>=20
> drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>=20
> First get the regmap, then the 1st argument is the offset in the regmap,
> the 2nd and 3rd could be the bits.

So, for one driver the extra arguments are: <reg> <start_bit> <stop_bit>
For another driver (the stmmac example): <reg_offset> <reg_shift>

Phew... Then we should really have a "syscon-raminit" property probably,
so that at least plain "syscon" has a consistent syntax?

>=20
> > So, I'd rather drop additional arguments.
> >=20
> > Why would you like to have it encoded in DT?
>=20
> Where put the information then? Into the driver, but where do you get
> the reference which instance of the DCAN you are, so that you can look
> up the correct bits?

Agreed. I thought we had this information in the driver already, but we
haven't...


--soWJpSPh+l8Y6Fy7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUKst+AAoJEBQN5MwUoCm2vGkP/jheXaSqCiV0tLnEp+ZjiX4j
qsIurasuMyPVfC+sekM8gExkWiAuNW06uthsoBf4JuRSDsKWQZY4VvaDhRofDE8u
d11uddMHBQaeny9crD9bTmshQKcKZ07qP68jH3vZmN++8vrtYfy6xD3YkqRapiPi
yeRban8P931/kLx/iG8AQl3q5+najyTCpfYJOmJpPbKA5guiHSBZ/j6/FYSW0Ia0
ZZFmAq5AbyGXfiNHIgNyS45T25cPz++X4shr3u1713t06oM5Qufphp2ikKnFbeXm
z4znCbBUCAGo7lLJnjdY9f17YpGhs6jScS4cxvqKd4mknVxnDmZ3aRlenPPZA6iA
HFzXoIx6EyYpaOu9qcRFot/o6oe+ua15UQZ48vuCUQ2G/jD9HyUoMfFLcgCo6fbe
Fhqr66Pcd7jYx8wNgc0OS+mgYE96CHRVLRe3A1A9STSlbgDPjmlEyHHC6p8GH/Vo
uJdQ08WOJq8KrhXV1sS0sw9JVdmoMM6co5YeWVLO28bDPtyNQuUu64Al2vq72Unx
u23KXOHMekJD3iHCcODkki1Tjz0AJT/93kd4QhwcE8DlofagNNfZS9cnx+/VYId8
5bNx+YkQz3j9I+Psj/5SeaX5Dk6JA1uvoQJTyaqrxYyPRZZIIBh8uV/rzvAICRug
Ur3v6A/EGjQjut1S86CR
=UAn6
-----END PGP SIGNATURE-----

--soWJpSPh+l8Y6Fy7--
