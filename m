From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20160104 build: 3 failures 15 warnings (next-20160104)
Date: Mon, 4 Jan 2016 16:50:25 +0000
Message-ID: <20160104165025.GN16023@sirena.org.uk>
References: <E1aG3zo-0000gt-2t@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="oWj5HoUXCVjyUFuT"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Igal Liberman <igal.liberman@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:35649 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbcADQun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 11:50:43 -0500
Content-Disposition: inline
In-Reply-To: <E1aG3zo-0000gt-2t@optimist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oWj5HoUXCVjyUFuT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 04, 2016 at 12:12:20PM +0000, Build bot for Mark Brown wrote:

Today's linux-next fails to build an arm allmodconfig (and probably also
at least arm64 though other errors prevent that getting to linking
currently) due to:

| drivers/built-in.o: In function `dtsec_restart_autoneg':
| :(.text+0x30f86c): undefined reference to `mdiobus_read'
| :(.text+0x30f89c): undefined reference to `mdiobus_write'
| drivers/built-in.o: In function `dtsec_init':
| :(.text+0x31008c): undefined reference to `mdiobus_write'
| :(.text+0x3100b4): undefined reference to `mdiobus_write'
| :(.text+0x3100dc): undefined reference to `mdiobus_write'
| :(.text+0x310128): undefined reference to `mdiobus_write'
| drivers/built-in.o::(.text+0x310150): more undefined references to `mdiobus_write' follow
| drivers/built-in.o: In function `dtsec_config':
| :(.text+0x310804): undefined reference to `of_phy_find_device'

and various other linker errors caused by the fact that the new fman
driver uses PHYLIB but does not depend on or select it.

--oWj5HoUXCVjyUFuT
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWiqLQAAoJECTWi3JdVIfQw+YH/2jMB/LT8N+DFrTooXClhCbo
pEYG/jkc3xZzOI9aCg2GjCMBq51hc+eRMJUc8KrT1OU6N1HH/qONBCktlgkvW5JV
xsXCFwHZr26IOrKysfXAYn5oSxnF0KmUlR7zy4t8imUh++REhal9D4k3bkWC8tqx
K5NX+tHl3gZtKmznlmbgMgB+foMMZRK9ziftiymtWujtHzwdycyip4q3YLmA2Krz
Q81jnxUYH1KmH9MCySLekl+nOH3uFzjVyFCtAkhapEYYYK3HaLk3dpzw/mYBrdQB
dUsku8mMV3soSAgsCsW/GXVPFqrzA5RL+LMgUXmgznwIktu7La0AK7xMgyxq9dE=
=U39K
-----END PGP SIGNATURE-----

--oWj5HoUXCVjyUFuT--
