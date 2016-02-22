From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20160222 build: 5 failures 9 warnings (next-20160222)
Date: Mon, 22 Feb 2016 19:19:18 +0900
Message-ID: <20160222101918.GY18327@sirena.org.uk>
References: <E1aXlz4-000486-Pb@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="57G+vFki3OF1XxbO"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1aXlz4-000486-Pb@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--57G+vFki3OF1XxbO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 22, 2016 at 08:36:46AM +0000, Build bot for Mark Brown wrote:

Today's -next fails to build an arm allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/net/ethernet/ti/netcp_core.c:1846:31: error: invalid type argument of '->' (have 'struct tc_to_netdev')
> ../drivers/net/ethernet/ti/netcp_core.c:1851:35: error: invalid type argument of '->' (have 'struct tc_to_netdev')
> ../drivers/net/ethernet/ti/netcp_core.c:1855:8: error: invalid type argument of '->' (have 'struct tc_to_netdev')
> ../drivers/net/ethernet/ti/netcp_core.c:1856:28: error: invalid type argument of '->' (have 'struct tc_to_netdev')
> ../drivers/net/ethernet/ti/netcp_core.c:1857:21: error: invalid type argument of '->' (have 'struct tc_to_netdev')

caused by commit 16e5cc647173a (net: rework setup_tc ndo op to consume
general tc operand) in the net-next tree which looks to have a missing *
in the rewrite of the function arguments for that driver.

--57G+vFki3OF1XxbO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWyuClAAoJECTWi3JdVIfQ2CcH/iFCXu1VpkjdxSnMcB3r0Ct5
axIrxFqR2opXXXKPe4T8axj1PHGGY6/EtQ5NejyhTRrdjRQ7Y1pyJ97i6qU6TFH9
ocjouak5eknNiQ9pm6eCVGGREo1qiIsbTT1WFKZr23ZtdQHSU5Zzm+oCQAqf6ZAc
q0gxypnBmQt+4B/hRHmPb0OCLGY9p1WXB4zfXJ174LZ5TYrMKL7fBLSitvRazuTF
pa3Ne82yHrqDv8Bxx9tpfK7NOloFldG9jCceP7zbjdn57GqNcy+lXoo6BFItEGOt
fKjAGxG64N//NPQ0obWD+lYSHGfFQYwodpcApXrB6uL2URPJ3XQBy2ximwNgUWk=
=7c+Q
-----END PGP SIGNATURE-----

--57G+vFki3OF1XxbO--
