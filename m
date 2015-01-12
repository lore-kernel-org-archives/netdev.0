From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 01/04] can: kvaser_usb: Don't dereference skb after
 a netif_rx()
Date: Mon, 12 Jan 2015 12:05:42 +0100
Message-ID: <54B3AA86.80601@pengutronix.de>
References: <20141223154654.GB6460@vivalin-002> <20150111200544.GA8855@linux> <20150111201116.GB8855@linux> <20150111204952.GC8999@linux>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="4PlGDeJOEFVMrRB3MARqu2Kfs0klrlCr2"
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20150111204952.GC8999@linux>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--4PlGDeJOEFVMrRB3MARqu2Kfs0klrlCr2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/11/2015 09:49 PM, Ahmed S. Darwish wrote:
> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
>=20
> We should not touch the packet after a netif_rx: it might
> get freed behind our back.
>=20
> Suggested-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>

Applied to can/master.

tnx,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--4PlGDeJOEFVMrRB3MARqu2Kfs0klrlCr2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUs6qJAAoJECte4hHFiupUIo8P/As2NRoUap9CJAq1ryczTUof
TwOkhzFgCdXQO+h9jwP5QCeKWxHjNZyLsT8cJ7M+5S1fWzG4XMPHJ9PRnyNi8+l7
7pDcMy7t0Ag53r0lumErv+Du9h/SoPZUOWknzUlPnIxNSevjZiVjiGLLZY6ultEq
KwGK1e4xOYCvmD1EWSFMb4Z6zo+YrSVPGKf1Goan6pnMRCU9gtXYfAYAixpTOiiq
p5PHgRP8qNJZ2q4u7F/M4a06v7SN9zckSYJgFAmN90AFU4DrllduRZwDt9BChWdF
C6vHG5Ziyf2fJovq3QHnuuRrMc93fGxJpkNVOJLXWo5bGpuu+WPYbiJ14hkHFw+J
CEbw5+HlxkyyZVUbjVsDYZcWcIit0o1ugbWnARmxa9yLqT//3staTzZ2IL5RnbON
lu84vWMoTCaw3z8QrbGPNUsdVTJO4oibbB6n2YCD9snHIws069HI+7tyztYl6wOn
dvgjzw3hDEuq6MmAEJqcmLqqq2jyAJ47B6xsi8ZASSBMq4wENH0OsV3AcEcBEQ0N
OsJ4U0mJyg0o8Vht+AapsNowEbXAM21BoTjBGIbv22xa9AAryg+YIf0uEU36UiET
5Mfrgz9wDyCfdp9mgewx2OfPoL8npVJDAld4ltWwIJANfguYM4I0/42Am85zrRB6
5qEGMDPUTcaMlM8vwv3P
=jS76
-----END PGP SIGNATURE-----

--4PlGDeJOEFVMrRB3MARqu2Kfs0klrlCr2--
