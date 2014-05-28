From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging tree with the net-next tree
Date: Wed, 28 May 2014 18:28:24 +1000
Message-ID: <20140528182824.63672ad9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/K.V47Y2h8HC5yHcLZwqcdZZ"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Sachin Kamat <sachin.kamat@linaro.org>
To: Greg KH <greg@kroah.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/K.V47Y2h8HC5yHcLZwqcdZZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging tree got a conflict in
drivers/staging/rtl8821ae/core.c between commit 77be2c54c5bd
("mac80211: add vif to flush call") from the net-next tree and commit
0cd05ba54a53 ("staging: rtl8821ae: core.c: Remove version specific
code") from the staging tree.

I fixed it up (the former is a suberset of the latter for this
particular conflict) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/K.V47Y2h8HC5yHcLZwqcdZZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJThZ4tAAoJEMDTa8Ir7ZwVSLIP/Rvlj7PQQUiRMxyF6NJlwr9w
SdUzpLz6d6+K/aJUAaLWTUrw/Sk3P8B8jI0/9z/N3wdNsBGwCpClvj46P+XajrDW
YOt5CdrsRb1/1ZCDZVtGW7w7BWRhjGwawCec+Y0+zusChwn7q01lNl651T7ebIJw
UmuSGN2K8zIPybysU+hvnJdd4vqM3rsFKn3j6e2pcrxkKb80c0FunyLJCqu5Tbc4
SjOvMV3IuxJWf21OzmToF/afsZ/FNej+iYXeNModtpzuKEb+PL+9zHtMXjntyT4M
QRava/VKA9RSFfKAxlhE/OHf4AWYn01INbrd7aHbho1HF/Ev6eo8y8oaW7pAobdi
jddBlFMDqLRtIiRuNTpbRd/22xmEGmlO1GLlL53h0UzFGiT6t7htskel+MX7apUv
kDRh6lCIM0hFR3QyroorZq/O8oN8OyQHmyFqkf78ZO0wWT2HOOla3WCfatqoe/t7
Pe1VkMrSrTKEKnVWeX+Nxrp8FwVG7MKCC0XXDyzK1h8+704dRq92h8+I3FqDQfyl
fro/KBCP9Oag8LlBwGCQT3FmftiWaEz6egE7iAqB/3lf1MjQN/40l5AhcNTB7gYh
Lfpw1q1+r8ouz2P13uSL1vshli3SCGnKkdm7oM/vqB0eRO2HjAqXTRXSGR5ChFBy
1gDEYn8U0idFOboJsG46
=lWkz
-----END PGP SIGNATURE-----

--Sig_/K.V47Y2h8HC5yHcLZwqcdZZ--
