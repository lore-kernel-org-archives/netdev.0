From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg is
 marked volatile
Date: Tue, 6 Oct 2015 15:31:47 +0100
Message-ID: <20151006143147.GR12635@sirena.org.uk>
References: <20151005.232956.105884641412802470.davem@davemloft.net>
 <20151006101305.GG12635@sirena.org.uk>
 <ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
 <20151006.062508.168154086334967576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="rPdL5sOQ4GFWV+a5"
Cc: jonringle@gmail.com, jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jringle@gridpoint.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151006.062508.168154086334967576.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--rPdL5sOQ4GFWV+a5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 06, 2015 at 06:25:08AM -0700, David Miller wrote:

> > 4) David should then merge the regmap for-next branch into net-next

> Nope, this doesn't work at all.

> It is my tree which people depend upon, not the other way around.

Yes, it does work - this is the way we normally handle cross tree
issues.  There is nothing about pulling code from other trees into your
tree which will stop other people depending on your tree, obviously
anything you merge in needs to stay fast forward only and ideally not
make any resulting pull requests look terrible but that's really the
only restriction.

--rPdL5sOQ4GFWV+a5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWE9tOAAoJECTWi3JdVIfQJBEH/0RyOjl+Qf34USN0sIR4SAZh
zMqUpOk+DYaj2BQy/SXHYqQ0qAy7zFN8JJgkTtaV9HQhUlPiHSffvoI5QTa79QvR
JOamwsEvRxPogQocvDfqYyEq3PMIPnBXgSHusXkGEil2Ahpxkr6rwEqd+4WHS2p4
YRdhwTspBsUlEzk8rdFX/ilKI96igeEuUCyG9GukblTVElmKuOWsWWCzRkQKiDYL
VR1afcS8uW1JgpGl+DbpMeAla/27U4O8fSNMNz8fCGmSNIVanFaBFbqObLKtr1QL
7KAfoL1uLDJzU7hWKgdLFOtKhR+KiPJfGm+giTv7JSRdLQpbd7gytztccLxp4Ww=
=1pEH
-----END PGP SIGNATURE-----

--rPdL5sOQ4GFWV+a5--
