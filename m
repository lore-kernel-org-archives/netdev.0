From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20160701 build: 2 failures 5 warnings (next-20160701)
Date: Fri, 1 Jul 2016 19:15:57 +0200
Message-ID: <20160701171557.GB6247@sirena.org.uk>
References: <E1bIuIz-00085X-RP@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="j6Ejlva3tMw3xXYi"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: John Crispin <john@phrozen.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:34330 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960AbcGARQT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 13:16:19 -0400
Content-Disposition: inline
In-Reply-To: <E1bIuIz-00085X-RP@optimist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--j6Ejlva3tMw3xXYi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jul 01, 2016 at 10:00:09AM +0100, Build bot for Mark Brown wrote:

Today's -next fails to build am ARM allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1300:2: error: implicit declaration of function 'mtk_handle_irq' [-Werror=implicit-function-declaration]
> ../drivers/net/ethernet/mediatek/mtk_eth_soc.c:1300:25: error: subscripted value is neither array nor pointer nor vector

due to the recent changes to the interrupt handling code, the function
has been split into rx and tx functions but the NET_POLL_CONTROLLER code
hasn't been updated.

--j6Ejlva3tMw3xXYi
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJXdqVHAAoJECTWi3JdVIfQO2MH/j+NzZjHLWOgTxyh8eYR4lzg
j47odvfmLt5f/JJtORRffwoR1QNMjNf2LrpnVSk3QNsQEXCPU0kQ7/kVoUghrUbR
Za2tYpD49QXge0ZSCqAepKzNnOMDfbOmPJOZClq9X14mp3GAZ0LA/vV1joKrkqJj
a8HfSihFu4hW3SgfhfwLLBLan+aXyoL0lKRD7mxJWBGuhNVWQfu4WkKqLLzvvUKq
dEKOqXNHo9AM1EnOaZsl6iOqGVZyWhcVP/W8SWtHqedgOSJtWxHFJA23i13iU2T3
ON4PGsYaHPbJ+N9YYHP509FOOjyHM6L2DsIixziD/09riw97yI9dZcMXvvQd2qg=
=51wI
-----END PGP SIGNATURE-----

--j6Ejlva3tMw3xXYi--
