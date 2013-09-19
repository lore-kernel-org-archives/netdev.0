From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCH] net: tsi108: Prevent compiler warning
Date: Thu, 19 Sep 2013 13:14:06 +0200
Message-ID: <20130919111405.GA10852@ulmo>
References: <1379508595-30252-1-git-send-email-treding@nvidia.com>
 <20130918.123853.1464055976885078627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130918.123853.1464055976885078627.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 18, 2013 at 12:38:53PM -0400, David Miller wrote:
> From: Thierry Reding <thierry.reding@gmail.com>
> Date: Wed, 18 Sep 2013 14:49:55 +0200
>=20
> > The dump_eth_one() function is only used if DEBUG is enabled, so protect
> > it by a corresponding #ifdef DEBUG block.
> >=20
> > Signed-off-by: Thierry Reding <treding@nvidia.com>
>=20
> I would prefer that this function and the one call site is simply
> removed instead.
>=20
> This kind of thing can be provided via ethtool register dumps
> and therefore without all of the ugliness this ad-hoc stuff
> presents.

I just noticed the warning during some test builds I was doing due to
some unrelated patches and thought I'd clean it up along the way.

I'll send a patch to remove the functionality completely if that's what
you prefer, but I won't be able to reimplement it using ethtool. Perhaps
someone with actual hardware can do that.

Thierry

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBAgAGBQJSOtx9AAoJEN0jrNd/PrOhnT4QAIelrNP+MLJmxaxZq7wfGqcZ
FViGIYuYfKPUjCYJ+jsihfyYJaLrpFsiYensrivPqEpdwRqOfYVY2jEw1AVRfwa8
x9oVRbnylRJlxY8ztBpY2vm1TEpBQn8aXa1YReELWtEe2f4yEmYWBIm6NpjoHlnn
Sc9UCtU0LMSaAY3/NRCutCEeEWYGF1I7b9ML4fPVYV61d+3hNAy+3vbZCugGUpM/
WtaXrFn0XRGsa5yS5uDCwUQEscTOFfqtvj9mxkxNrLy2BJyhUPMgvQzUqfFsAnAk
i1q1k++E9f4M4BDCfCQWB26oy92FC9K/hXQVtimQmIPM0vdLtq/cPm/67HY3+A84
avzN+XKPNHtMpQcxSrIUQnh0juLIoOlGBJD9tRGUbqOQS52pE10/AKlcjYWChNAb
3zZng+lkW2ug06nCpkPf8wlpO3KQz1Hw9LhCnAa6Vy6YYpPkLY76r32yEawHcs0z
Oc28mEqaFVCw7sUoCECnuV+0ZYSYO4SDGynEeouD+c/3yo3U3WcgQsh1L2gAtq2n
nN4HO7d7cJmC5u0DHkNff96IoRjcIT2XLdij2NbLYMzqV5N43BfyS0OQhuz9T6OM
xzLPsCqoNPBPJmZm/ljNrxNuOR0vlzJ9YJWfgxCq2lnc2KYtoeS2LSLCIIQd8I67
4U/jajMZbg9Pgi+r1Wcf
=SUIx
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
