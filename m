From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Mon, 23 Nov 2009 12:00:52 +1100
Message-ID: <20091123120052.dd388203.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__23_Nov_2009_12_00_52_+1100_CnAuE2zDVY_yjpMK"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755913AbZKWBBA@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__23_Nov_2009_12_00_52_+1100_CnAuE2zDVY_yjpMK
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/ieee802154/fakehard.c between commit
56cf54831fd1be105e89a9df899e3b22442da180 ("ieee802154: dont leak skbs in
ieee802154_fake_xmit()") from the net-current tree and commit
8964be4a9a5ca8cab1219bb046db2f6d1936227c ("net: rename skb->iif to
skb->skb_iif") from the net tree.

The former removed the code modified by the latter, so I used the former.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__23_Nov_2009_12_00_52_+1100_CnAuE2zDVY_yjpMK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksJ3sQACgkQjjKRsyhoI8zqBQCgrqL0/XwoyIDqQ+1sZ6NFaXf4
qE0An2cN4A4jUJsYFObSaHl/fOcA2pXS
=MoYn
-----END PGP SIGNATURE-----

--Signature=_Mon__23_Nov_2009_12_00_52_+1100_CnAuE2zDVY_yjpMK--
