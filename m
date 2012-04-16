From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Mon, 16 Apr 2012 12:49:06 +1000
Message-ID: <20120416124906.374bf01698ec4c199d1a6f7c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__16_Apr_2012_12_49_06_+1000_gmApyn10SXO1t.qT"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Eric Lapuyade <eric.lapuyade@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:53276 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810Ab2DPCtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 22:49:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__16_Apr_2012_12_49_06_+1000_gmApyn10SXO1t.qT
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
include/net/nfc/nfc.h between commit 95c961747284 ("net: cleanup unsigned
to unsigned int") from the net-next tree and commits c4fbb6515a4d ("NFC:
The core part should generate the target index") and 01ae0eea9bed ("NFC:
Fix next target_idx type and rename for clarity") from the wireless-next
tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc include/net/nfc/nfc.h
index 79955a2,313d00f..0000000
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@@ -86,7 -90,8 +90,8 @@@ struct nfc_genl_data=20
  };
 =20
  struct nfc_dev {
 -	unsigned idx;
 +	unsigned int idx;
+ 	u32 target_next_idx;
  	struct nfc_target *targets;
  	int n_targets;
  	int targets_generation;

--Signature=_Mon__16_Apr_2012_12_49_06_+1000_gmApyn10SXO1t.qT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPi4iiAAoJEECxmPOUX5FEfqEP/2bIQ19jm1n/kWeC3p9SWzlx
Sx/pr7zxgk7NJ3DNMLh2DCULuuuvGozx7lk2c82+tT0theVDkMTKfjEi6nY/5VH1
EAV1w84SCkfSgCURffaGb7NJcXVW8JvCwqBRD+N6jy4RuqgkHzKfLfEgQNSsbIcP
w7epMbuKO1cT8Ckbd8fMSQdsr/+6e+ZK0VvnvsJvf/IqUAOCfvmJ/3RXNLf4BmJo
qufwoOCGBieGWB32pS0/OVSVVzw8QtUB2NvpdpCOsTkOxYt1VQprvNf6eno0oCkt
ArPZ61APJ5NThrnQ0MNlfGp6dygckb3TtbtZwapyuyGendV9CcRmQDMJQzxwm5nQ
AcqQTsIfHCZFXokeYTz/dWdUAyaR1hbTr3wJo/RRZ8aWhDacS+T9VCmZb0yjnRKD
UCWudBsCbgZshwcBLlBX74pk+LC47QMmy6c/QFFHaVWGncbU6IdPTkiMFu0AQtzN
ZChAj93qLQuiTPfQhGIacx9mvx9VUE1FLMW+bzp7TiXWQCNXQGAt+S0JmzqDsVJA
75goRZ5Gwd4U+HN9sDfWfFXayojo1Mk2R+7RzbP+tFdV/7cUwVQL76o1MPjC00KJ
teODDUkg8IWfPQP9AjMMd73IWnJTXzIDmW9lo8qT0rZblJAU2vZEJUsMQKGrMMxq
B5Y2QvewqI6cQBF7HmHL
=ma0K
-----END PGP SIGNATURE-----

--Signature=_Mon__16_Apr_2012_12_49_06_+1000_gmApyn10SXO1t.qT--
