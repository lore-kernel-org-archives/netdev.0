From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the pcmcia tree with the net tree
Date: Thu, 16 Sep 2010 12:31:52 +1000
Message-ID: <20100916123152.61d6e10a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__16_Sep_2010_12_31_52_+1000_wV9LWLOtLJgb=iHu"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__16_Sep_2010_12_31_52_+1000_wV9LWLOtLJgb=iHu
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dominik,

Today's linux-next merge of the pcmcia tree got a conflict in
drivers/net/pcmcia/pcnet_cs.c between commit
7136e11e0cf520ab3fc7b55a20e60c2ec5ea88e1 ("pcnet_cs: Use pr_fmt and
pr_<level>") from the net tree and commit
b76dc0546709aef18f123847680108c2fd33f203 ("pcmcia pcnet_cs: try setting
io_lines to 16 if card setup fails") from the pcmcia tree.

The latter used dev_notice/info (and moved the code) where the former
used pr_notice, so I used the latter.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__16_Sep_2010_12_31_52_+1000_wV9LWLOtLJgb=iHu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMkYGYAAoJEDMEi1NhKgbs5PwH/RO8WGsdtjiL+QtZaeeV8CQV
1shJDcr8YCwtWnYvNPBsX8aYy3HuVGG5MXEct1Uwi6LChWfH1XfftvtJ1NlmEvvk
smdTyoSDORPjaYrPTvVq3ZEAxL4ttx0pNPzq0m+alMsGnHYsKySY0ZrXr6DFXvp3
iNWOhaGIG/FNg3LxqmQG4HO0j2c+rNhSzY+IJJm0sRaJlTp3rGwh8S0jUWruxb8F
g1AcpLyjntZ0kMAGZUqSs0SNxH+M3dY/2xMfmeSlV8GdrDfMcCP3Ja9CmydQuPJn
9F03I0ZSvFiGeFf26mc4Cywfw/MiGLy6AObioRn6UFut492i9iWFIGt78ekSxOA=
=O/0W
-----END PGP SIGNATURE-----

--Signature=_Thu__16_Sep_2010_12_31_52_+1000_wV9LWLOtLJgb=iHu--
