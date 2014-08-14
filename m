From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: c_can: Fix return value check in c_can_plat_probe()
Date: Thu, 14 Aug 2014 12:11:35 +0200
Message-ID: <53EC8B57.6070300@pengutronix.de>
References: <1407977939-15287-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="xTHf24oj5adGBeUdotujF50GRjsdkRsSL"
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: weiyj_lk@163.com, Wolfgang Grandegger <wg@grandegger.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Chen Gang <gang.chen@asianux.com>,
	George Cherian <george.cherian@ti.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>,
	Pavel Machek <pavel@denx.de>, Thor Thayer <tthayer@altera.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Wolfram Sang <wsa@sang-engineering.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1407977939-15287-1-git-send-email-weiyj_lk@163.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xTHf24oj5adGBeUdotujF50GRjsdkRsSL
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 08/14/2014 02:58 AM, weiyj_lk@163.com wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>=20
> In case of error, the function devm_ioremap() returns NULL pointer
> not ERR_PTR(). The IS_ERR() test in the return value check should
> be replaced with NULL test.
>=20
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Dan Carpenter already provided this fix. It will be included in my next
pull request to David's net.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--xTHf24oj5adGBeUdotujF50GRjsdkRsSL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlPsi1cACgkQjTAFq1RaXHOG+QCbBcCEd47GOKmJq2SRwo/WxshI
LX8An0aSDZkCPONqP23zyNm0rHtPmspO
=1+wN
-----END PGP SIGNATURE-----

--xTHf24oj5adGBeUdotujF50GRjsdkRsSL--
