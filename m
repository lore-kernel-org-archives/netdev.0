From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20170330 build: 2 failures 8 warnings (next-20170330)
Date: Thu, 30 Mar 2017 17:09:53 +0100
Message-ID: <20170330160953.z4qvueywbb6reyu7@sirena.org.uk>
References: <E1ctZXC-0008DB-4g@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="nnmtzmpkdz33ic3s"
Cc: kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Joel Stanley <joel@jms.id.au>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1ctZXC-0008DB-4g@optimist>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nnmtzmpkdz33ic3s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Mar 30, 2017 at 01:50:39PM +0100, Build bot for Mark Brown wrote:

Today's -next fails to build an ARM allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/net/ethernet/faraday/ftgmac100.c:153:9: error: implicit declaration of function 'device_get_mac_address' [-Werror=implicit-function-declaration]
> ../drivers/net/ethernet/faraday/ftgmac100.c:1262:6: error: implicit declaration of function 'of_machine_is_compatible' [-Werror=implicit-function-declaration]
> ../drivers/net/ethernet/faraday/ftgmac100.c:1406:6: error: implicit declaration of function 'of_get_property' [-Werror=implicit-function-declaration]

This driver is using DT and device property APIs without explicitly
including the required headers and has been relying on implict includes,
it should instead include them directly.  I've sent a patch for this.

--nnmtzmpkdz33ic3s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAljdLdAACgkQJNaLcl1U
h9De5wgAgpirTf+o1ljbqb0JX7OshOoYFxLPBUkAUuG/mmJp9bCYeVLh9yz+U4cg
hC2weSAEUAtg+Lio5a8cAFyj79LTmLSqOb3ai7aRdOIFp3NWxBX0PDZWDUyxXdwd
u5UKF/kX3JH9WvB1o6M4Km4MJSJ0PCszkPf48P/bqwbqpHaRRl7eN9RLFsHUsThe
dkPAIL8FeP3jri4SxW4mh3zy0a+1RucVQ8flZjB3U3As+QPHQKHA9xCQslw9Oirk
18IpK1LfV/m2kE6U9eBza4H77R0voz1SQIciSOk/9K+lQszTkksS+WiZKA5UJSFQ
u4NzOnnSIrfG7DMLt060vnyUYXCRZQ==
=1wxD
-----END PGP SIGNATURE-----

--nnmtzmpkdz33ic3s--
