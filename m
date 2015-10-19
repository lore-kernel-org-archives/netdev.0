From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH v2 3/3] net: wireless: b43: Statics are init to 0
Date: Mon, 19 Oct 2015 18:11:57 +0200
Message-ID: <20151019181157.7018b25c@wiggum>
References: <1445270543-2209-1-git-send-email-paulmcquad@gmail.com>
	<1445270543-2209-4-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/a3tsOcnxoqCEKWZoSzYSI27"; protocol="application/pgp-signature"
Cc: kvalo@codeaurora.org, zajec5@gmail.com, davem@davemloft.net,
	joe@perches.com, johannes.berg@intel.com, sd@queasysnail.net,
	mike.looijmans@topic.nl, khoroshilov@ispras.ru, cengelma@gmx.at,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul McQuade <paulmcquad@gmail.com>,
	=?UTF-8?B?R8OhYm9y?= Stefanik <netrolller.3d@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445270543-2209-4-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/a3tsOcnxoqCEKWZoSzYSI27
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 19 Oct 2015 17:02:23 +0100
Paul McQuade <paulmcquad@gmail.com> wrote:

> diff --git a/drivers/net/wireless/b43/phy_lp.c b/drivers/net/wireless/b43=
/phy_lp.c
> index 058a9f2..086f0ba 100644
> --- a/drivers/net/wireless/b43/phy_lp.c
> +++ b/drivers/net/wireless/b43/phy_lp.c
> @@ -2502,7 +2502,7 @@ static int lpphy_b2063_tune(struct b43_wldev *dev,
>  {
>  	struct ssb_bus *bus =3D dev->dev->sdev->bus;
> =20
> -	static const struct b206x_channel *chandata =3D NULL;
> +	static const struct b206x_channel *chandata;
>  	u32 crystal_freq =3D bus->chipco.pmu.crystalfreq * 1000;
>  	u32 freqref, vco_freq, val1, val2, val3, timeout, timeoutref, count;
>  	u16 old_comm15, scale;


Why on earth is this static anyway? That seems really wrong here.
The static should be removed (and the =3DNULL init be left in place.)


--=20
Michael

--Sig_/a3tsOcnxoqCEKWZoSzYSI27
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWJRZNAAoJEPUyvh2QjYsOw/MP/3uHGnU6KBMDfkVFovLSFuQh
FyySSsrlE1r3nyM1iqUF3c9AAoQjFqLD/7nBID20oXzbXxR14FcdJYxp+plS94f4
GjyYseEgkphw0Rbn+xMnjFGaZqlzv4n1CaKs0A2TLaarAGU24wNyDiFnBWiQiwV2
lwfYuS+X5lRQJf7d2DI5BtntYFf2BP3ez8ii4cok93o5/izhfMm+RK6yTpu/X9Q1
cKgWi0bcerhjiBsOv/ICp8WkiSMtn/Y5yMCzE5cdf+LO155IYoSoNuNX/2jNnTpN
6ND+w3xgZ7Gls9P3PqMimtRHPW07IE3TylUiy4NE2L6orVXgZn5C5XJQPKA+VZil
Fmy/rQhXMU59t19xPDy0RCl5dNEPgIVEeDDm1vWccl+HtPfImwh4EpyWNaDqOV3B
DKM3DNHASM0prtIkkNRrdkiXATGbW6uGdi43cEOKu+Lx3ZMqeJlDrrhrhc0LJWZP
vP/1q3/2395BV55B6OC5DFqphYl1S8d7oXmEcVtzHKZ5NEC3INsyCmozKBw2qvy3
2iz/n0Cz8Xw8C4pFOs3qMjEXAZHcQ7IJNrvm7SOJoUpAWX/ZOIcQevvRjFlSJLfN
nP/cNFJncUqncQ8H67axWJc0hsWZM4vsXF7O5d7RJ2HC27M/T1VCn+qyGUp0Bjzy
0bH+Uas85u44M2kv/Fjc
=tYVm
-----END PGP SIGNATURE-----

--Sig_/a3tsOcnxoqCEKWZoSzYSI27--
