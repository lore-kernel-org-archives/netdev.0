From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20160816 build: 1 failures 2 warnings (next-20160816)
Date: Tue, 16 Aug 2016 17:38:41 +0100
Message-ID: <20160816163841.GU9347@sirena.org.uk>
References: <E1bZaoA-0004xE-Oj@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="00zH/wdDQmWzr4bS"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org
To: Saeed Mahameed <saeedm@mellanox.com>,
	Leon Romanovsky <leon@kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1bZaoA-0004xE-Oj@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--00zH/wdDQmWzr4bS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 16, 2016 at 10:37:20AM +0100, Build bot for Mark Brown wrote:

Today's -next fails to build an ARM allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/net/ethernet/mellanox/mlx5/core/debugfs.c:300:61: error: 'outb' undeclared (first use in this function)

which appears to be caused by 535e20f083e6 ({net,IB}/mlx5: QP/XRCD
commands via mlx5 ifc).  outb() just isn't available as standard on ARM,
it's not something that's meaningful for the hardware.

--00zH/wdDQmWzr4bS
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXs0GQAAoJECTWi3JdVIfQiX4H/iiH3VkZfY66gGV542x56tRt
pM4JLiNISQesuGC/MUsje7QHddEoOi/6hbXRSWOFnQgl95LsCgZ2ObWJCKsDiO6Q
6PKx8lMgfptozqm24/pTF9ClsCru1rS9wcy/EPirEvOZ2nacgIO1JLt7iBBauSgw
m6nQuuUJoM1xQxjo9JUfTK2yVxaZ+0ca+5zBpt5vSe8i/ETc5ogM2oZEQgiEIBI2
MFbniiB7jfSZXifTgGF02lVFetXxz0Vk2YuHtvpuYhTEaS4w5BWE3ZXbrrszVVas
EnnPy/SFSHX2COxIjMFFGYTaPaQcvdMKLN4+GFgy4ktKnls00A1nqVQudKntXA8=
=hABn
-----END PGP SIGNATURE-----

--00zH/wdDQmWzr4bS--
