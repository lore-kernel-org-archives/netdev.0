From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH net-next v2 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Tue, 6 Oct 2015 10:57:15 +0100
Message-ID: <20151006095715.GF12635@sirena.org.uk>
References: <alpine.DEB.2.10.1510050755120.27553@jring-w510-7m3g.gridpoint.com>
 <20151005.061609.75433802286337666.davem@davemloft.net>
 <20151005142531.GS12635@sirena.org.uk>
 <20151005.232148.28609721470208031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="yO52jeZL+8sEiVPY"
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151005.232148.28609721470208031.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--yO52jeZL+8sEiVPY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 05, 2015 at 11:21:48PM -0700, David Miller wrote:

> > Ugh, this is a mess :(  Can you please drop this patch instead?

> I can't just "drop" changes.  Once a commit hits my tree it is part
> of the permanent record.

I was expecting a revert if you want to keep the branch fast forward
only.

> The easiest thing to do is to send a relative fix, and that's why
> I have asked for exactly that.

This isn't very good for reviewing the API change, and of course I'd
also expect this change to be in the regmap tree so we can work on
regmap without collisions, I obviously can't just merge in net-next.
I was thinking about making some further changes on top of this and it
*is* fiddling about in the core.

Jon, please send me a patch against the regmap tree for review while we
work out how to sort out this mess.

--yO52jeZL+8sEiVPY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWE5r6AAoJECTWi3JdVIfQwBIH/i4b/AJFrdVbiNVAYPKCIIWR
EsxKLT6LS69AZXnKOuG+9DmFmyV7DLhGJpYo0XzFZcxYf3NFTpzrrBbgWAZbivQW
GPcmyLrflNqVV04JX1hVTrfM2cy8g92NLJNzNLoMptlgWQ2LyLemuVGFtLDi7Alg
qZi/aVsVTpqK5tHhWSMwjU8+3CEKTKD2HUkN3ZJrxMaV6gnqNdl2+z1eWmHZr9l0
W/9oDxAdC0xBGQ7OyIXeLjrhx2zzFTiJomKtuxixo+m8QVNd9+P+ZnbBI5M4qOvC
eIxa6nUvInKvCBHKuAvpwQ6FN9fSz5/D9x/1+r6+l5fbu3Xdnd6lFvtfsK8Nx5M=
=UMlH
-----END PGP SIGNATURE-----

--yO52jeZL+8sEiVPY--
