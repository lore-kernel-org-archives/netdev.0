From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Fri, 4 Jul 2014 11:39:07 +1000
Message-ID: <20140704113907.468a366a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/mPhV9I_S1UurY/j49mWzn5I"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vince Bridgers <vbridgers2013@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/mPhV9I_S1UurY/j49mWzn5I
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64
allmodconfig) failed like this:

ERROR: "phy_resume" [drivers/net/ethernet/stmicro/stmmac/stmmac.ko] undefin=
ed!

Caused by commit 0acf16768740 ("net: stmmac: add platform init/exit for
Altera's ARM socfpga").

I reverted that commit for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/mPhV9I_S1UurY/j49mWzn5I
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTtgXAAAoJEMDTa8Ir7ZwVeZcP/0n0d6L9lzzHZp/ACozLMYoH
bIi+TUaRSqdOx7O1MkoGZR4NlRokMkggf0Wpju2NTjA40r2vHK7Q7dOwpbWF6e5k
2uVNRCFJdyVI6LepHJirPiVAZWqdzvwT8fv3nVDCEWHe8ptN9wyZHS4XLAukkane
xpEXt/KWFoJJcZjkH95A+G9fl/qiUHJKI1wvB0vHy4JrwyS873S/csUWtxvL1cIn
8vYivymvhD/EgrhgWEIdtdKHIQQ+eMsuk+24cb8/sB6ykjRKpQl9LzJRvrxGNBRh
5NC8ebcQYiIT5GfDXP6C9w7oeVXZhhjyj/qLAgOvGNUAz8Q0TPDxjlUVsaa9Vq2A
XXG/SiFxtVBSjSTaSyeCoAadDV/mOilL4WUMQz5FpxNdsXrnzP+/UjELKkfTchqO
9yTnPLiHO24OsL8zdgga3T+iRfhwgxE2Lvct0jaJi8opd4Er+SscqXA1NE9zNkYG
rzzAYQtAC4Ua1Ajs4mZWxSEvYzF5mz90jDYjkQVePd+h3j1GHJuztF6Xla3CnCvy
IoSqFJNxdLsBHSa1OiNVnUMNHOLVEnMM7TZH7PCBsyQXMiYGmNcMVqSRjX77Y5oe
OCwFewhw+QRy4xKqEUKF98MKHmbgj5Tqlf7MaX1ccRojYEFNCOXtzmCiEoTjiZUL
nku6ogTa0Lr5X3pylaTP
=Ir2W
-----END PGP SIGNATURE-----

--Sig_/mPhV9I_S1UurY/j49mWzn5I--
