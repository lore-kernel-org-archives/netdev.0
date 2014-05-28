From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH] net: ks8851: Don't use regulator_get_optional()
Date: Wed, 28 May 2014 21:23:27 +0100
Message-ID: <20140528202327.GK5099@sirena.org.uk>
References: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3D7yMlnunRPwJqC7"
Cc: "David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Nishanth Menon <nm@ti.com>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401307872-23190-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3D7yMlnunRPwJqC7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 28, 2014 at 01:11:12PM -0700, Stephen Boyd wrote:
> We shouldn't be using regulator_get_optional() here. These
> regulators are always present as part of the physical design and
> there isn't any way to use an internal regulator or change the
> source of the reference voltage via software. Given that the only
> users of this driver in the kernel are DT based, this change
> should be transparent to them even if they don't specify any
> supplies because the regulator framework will insert dummy
> supplies as needed.

Reviewed-by: Mark Brown <broonie@linaro.org>

--3D7yMlnunRPwJqC7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJThkW8AAoJELSic+t+oim9FR0P/jTc6X1DYlh76vwgyJZMiKgI
CM5aX19PupQpsm5n91NStVNa5ls56GI/Wz+9PiLYxqKZrPRcsm1Iz84Bgozd1MYI
AeaiBKMPgIsZftYUe5+ap/lZXNq6SWtvSZaqQSVNRsRd9wj3mK300fXbIfw6Jv71
DENmtsPAtGv/1orSY2uuMJkR3/ZapmEzrZdJ6lmxyq0m5z6TZ/BRwvR5KiBI8dbU
P9ZQeDG//lYGrZ3hVPsicuPMV+Sv4qDXI7lHmUuefiZAQNNggyLcZ5hNw4xfG4ip
0dgCK2bfcuLIkrw1Fr5kO/Br6ISzy5ZJeKLeEo+ZtoY00elAnvf3TqfW65w/JVZl
UPnPmr92nRDv+cryyw63we6BcEnsqpeLspRLK9BaVXZNxW4ZBddurTN6m9prLxCL
Bc+9n/zImal+RHVDbkJyqKgk5Y9a30mIQC4oI6GAOGVhCqLL2inLIM8YsvO9T/xG
TAQ0TgQqNZl9UjBmxky5XEpnrFi+/l2xOyWQ3hMzDI1at25YRXOQcN20V6KRAWU8
gRy8OZOxDD1WI1oxhCMtLIucy+CfYUftv4MR06c0G0vNhK3RMS2EDFsH8WC4SiJx
kdFlZPLLD2127M3ZbNRSD67VEK16C8UGo/kfRkQaeHSw6m41qgrDvoukmRWRhyqP
bqj6CcsBZx8Oq5SjBBUy
=KqNG
-----END PGP SIGNATURE-----

--3D7yMlnunRPwJqC7--
