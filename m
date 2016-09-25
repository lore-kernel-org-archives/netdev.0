From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: mark symbols static where possible
Date: Sun, 25 Sep 2016 15:22:09 -0700
Message-ID: <1474842129.2751.4.camel@intel.com>
References: <1474783438-7278-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-rONEHRvWXWby2pI4vLer"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>,
        intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474783438-7278-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rONEHRvWXWby2pI4vLer
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-09-25 at 14:03 +0800, Baoyou Xie wrote:
> We get 2 warnings when building kernel with W=3D1:
> drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2128:5: warning: no
> previous prototype for 'ixgbe_led_on_t_x550em' [-Wmissing-prototypes]
> drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2150:5: warning: no
> previous prototype for 'ixgbe_led_off_t_x550em' [-Wmissing-prototypes]
>=20
> In fact, these two functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
>=20
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
> =C2=A01 file changed, 2 insertions(+), 2 deletions(-)


This has been fixed and pushed upstream, why do you keep submitting this?
--=-rONEHRvWXWby2pI4vLer
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJX6E4SAAoJEOVv75VaS+3OjQEP/2XDMCehjn6qvM43aauu53AX
Gn+j/07i3ekvBngTxsfsz3d9/jumJOktUrJ7uxPyqpkfzBTtx4IyLIgsUCAgdkwx
+SOJ3aPMo6Sj/PRr4u/GJnf1esrp0VEIDjUCjWmqxWxvzCljPU6Q/MJr5QjX/oXT
C2rkzcBMzAgaFVSyOU3r3FaFTCUJwYUqkj8OTq6HmluQyaMJn92yz3669Q9sEqsT
3CAx88d52SudPFuap4EMXQtS5FR+xFHg7Aqpob9biGdkPtnv+CbuU+bDcoKbKQM2
CCFxTqmsWFpUXfusHZCXW2jn3gxFxGUsGiLblD8P2hzWeQwQkNT+jkUqUiiWdKTz
DRLkSiisyqNvIiHkrmlL67lkD4vzFI3lStfeLCHYRx0j76Qrl4QJCwEnma7qkYH/
cGi12YSCoqt5koZHlXUh1k5WEThI25+cUdKtjowypijUPayBtBFoREkRdx2r1GtP
h3v3ocEWkOm3kDOYkTaFtlbQAludgSQ5jlJukBdxMmJr6XQ5TabyOSpoxr8AC56a
2oa2IrgFbkw+yJoZ3kj061fFDFo/Tyu2xBjNdotUNMFYDr0V/gn0MyJc++LewevS
FiD3z8h4QANUgIPZaLyKmqc2ZHdOzZZFgWdRZfsx+sMaLDl+b21KT1CvY/+pwe+8
fBVooQf22JkFLvS6D2fa
=/AbF
-----END PGP SIGNATURE-----

--=-rONEHRvWXWby2pI4vLer--
