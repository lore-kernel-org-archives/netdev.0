From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20151126 build: 3 failures 15 warnings (next-20151126)
Date: Thu, 26 Nov 2015 11:59:56 +0000
Message-ID: <20151126115955.GD1929@sirena.org.uk>
References: <E1a1sVV-00079q-My@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="NxDiCysn+RCvdoZt"
Cc: kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org
To: Shaohui Xie <Shaohui.Xie@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:49687 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbbKZMAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 07:00:03 -0500
Content-Disposition: inline
In-Reply-To: <E1a1sVV-00079q-My@optimist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--NxDiCysn+RCvdoZt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 26, 2015 at 09:06:25AM +0000, Build bot for Mark Brown wrote:

For the past couple of days an arm64 allmodconfig has been failing to
build due to:

> 	arm64-allmodconfig
> ../drivers/net/ethernet/freescale/gianfar.c:650:33: error: 'NO_IRQ' undeclared (first use in this function)
> ../drivers/net/ethernet/freescale/gianfar_ptp.c:470:22: error: 'NO_IRQ' undeclared (first use in this function)

introduced by fe761bcb9046029 (net: fsl: expands dependencies of
NET_VENDOR_FREESCALE) which enables build of the Freescale networking
drivers on arm64.  Since in common with many other architectures arm64
does not provide a NO_IRQ (and even those that do aren't consistent) the
driver should be modified to not rely on this and instead check the
return values of the functions it uses to look up interrupts.

--NxDiCysn+RCvdoZt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWVvQ7AAoJECTWi3JdVIfQWvAH/32oA97yRxdwJQeNR0I1PHw2
DTPupt9JHXuQj51zP34GX9utx4Tgr6pikOXTjSodrkk4gRqaB/7y+mp8Ix1lb02B
JFpdUEGoa3cMhsQXNjaQDbunwHyjmB+3zq07uVOqb5BiJ72SKe22vSUw/V9NDX48
wZREmzrh7glESYBeopCuxogu5BUCgHAhAawLJptcAh0KMzfrMp96/OW/5c/KMJjx
kr6WaUIOYyZUxPq/3BMwQ/dBhkMyUVBnivFWn4V+42t2vNhRQ3HS8+ACHCMmyf0U
hvS6LRxKiYXSXh07iQNEDDjnJB9+Fu/9w8bRMvkn7SudV+wZV1FIFtyTV+PdX+k=
=6A6+
-----END PGP SIGNATURE-----

--NxDiCysn+RCvdoZt--
