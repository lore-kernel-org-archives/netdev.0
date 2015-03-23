From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20150323 build: 1 failures 23 warnings (next-20150323)
Date: Mon, 23 Mar 2015 14:25:24 -0700
Message-ID: <20150323212524.GU14954@sirena.org.uk>
References: <E1YZyoN-00019n-50@debutante>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="niUlcCfh/sMBwTxc"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:55931 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbCWVZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 17:25:03 -0400
Content-Disposition: inline
In-Reply-To: <E1YZyoN-00019n-50@debutante>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--niUlcCfh/sMBwTxc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 23, 2015 at 09:38:19AM +0000, Build bot for Mark Brown wrote:

In current -next the bgmac driver does not compile in an ARM
allmodconfig:

> 	arm-allmodconfig
> ../drivers/net/ethernet/broadcom/bgmac.c:20:27: fatal error: bcm47xx_nvram.h: No such file or directory

because this include file is only present on MIPS.  This looks at first
glance to have happened in the merge commit edb15d83a875a1f4 from the
MIPS tree though I think that needs a bit more investigation.

--niUlcCfh/sMBwTxc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVEITEAAoJECTWi3JdVIfQwTIH/2bbM8JuRg/ySSgKEFWm1wK+
1UkTKAOyh8+FfoOFvbuDZyYHxNBygG0nNm1vnCHq4uwipv7qMNv9FCt+GdyR9sCI
hA6eAxEyqoqhgV3fMayVO5W1YD/NjMTR2gYDFVRkGP5OC1GSU61yuBWHgcI+NQqy
QuGzuRQj9CpuuQsnOVGkYN4C2nQMBmuzSI7/I1lX++5hZW3za1qlsLJmjvIIft09
u6N0AaSxgW6pYsp2Jkl7SzAw5A/cAqYVptJx1enUTTZWqNC0NqnjcAiUzxpY523j
IRZbVP/DpfCsuMOR6KAemvpCubVhQRbwUom8zNp+NyNZuUxZl5bfOPZU1NJjVdg=
=rG9K
-----END PGP SIGNATURE-----

--niUlcCfh/sMBwTxc--
