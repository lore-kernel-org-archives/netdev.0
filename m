From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20170621 build: 1 failures 7 warnings (next-20170621)
Date: Wed, 21 Jun 2017 11:45:06 +0100
Message-ID: <20170621104506.dduagkukisqhxayx@sirena.org.uk>
References: <E1dNcMp-0005RN-1w@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="g3xxw5z6mudwfkak"
Cc: kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org
To: Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1dNcMp-0005RN-1w@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--g3xxw5z6mudwfkak
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 10:56:07AM +0100, Build bot for Mark Brown wrote:

Today's -next fails to build an arm allmodconfig with:

> ../include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token
> ../include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token
> ../include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token
> ../include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token
> ../include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token
> ../include/linux/qed/qede_rdma.h:85:1: error: expected identifier or '(' before '{' token

caused by bbfcd1e8e1677b (qed*: Set rdma generic functions prefix), the
stub for !QED_RDMA just has a syntax error.

--g3xxw5z6mudwfkak
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAllKTjEACgkQJNaLcl1U
h9CSWwf7BJnyKPIx5NSbMIBY50CJ2EXV7DpXrE2FsImGbPMsg5IWuoRyEfyqpO0M
dqOgNXgb+s6vSH3xfDg8VFXb+e15sJO6nVD5p8lvp9f1ltLV+kynfBnUGZ47/K9v
Q7nwl8hr8ZmkJInxmvjEqQRI7Rqsr7CU2ub+EqR9u+3+ukID7igWWEMOGdg43QpD
Uup+mY44KBephVJfea6QIN3taSxFih+gDcOuA+MuH1jGC82L0JsYIBbHKsHdAn3u
Jr6mPe9sTs/lgtSOyANRz+HOvj7EVEzXvnCheUkgrd0DJBqZzzmhe7qAr1mhN0Bx
9f5xcHsT7DEM40NxSvOptZp9wD39KA==
=ullf
-----END PGP SIGNATURE-----

--g3xxw5z6mudwfkak--
