From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the target-updates tree with the
 net-next tree
Date: Mon, 9 Feb 2015 19:03:26 +1100
Message-ID: <20150209190326.374bf38e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/7zAhT8_=abQGpq/GjFsiRCj"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/7zAhT8_=abQGpq/GjFsiRCj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Nicholas,

Today's linux-next merge of the target-updates tree got a conflict in
drivers/vhost/scsi.c between commit 57dd8a0735aa ("vhost:
vhost_scsi_handle_vq() should just use copy_from_user()") from the
net-next tree and commit 09b13fa8c1a1 ("vhost/scsi: Add ANY_LAYOUT
support in vhost_scsi_handle_vq") from the target-updates tree.

I fixed it up (the latter removes the code modified by the former) and
can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/7zAhT8_=abQGpq/GjFsiRCj
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU2GnTAAoJEMDTa8Ir7ZwVTSYP/20M5y+xB1d+sovpADkAjflW
9y9Yj9bwBzgoe8gwMNhvflqDREh/PlZK+eDg5YmFoO9YK/51DJO1+EmKpmO3b3ZR
3HsuYMnKX0OLemOyDjhVSwPiZt7YkecuZ2x7fsFZnxc4vgtgQcNt1Ypt/Z+qdlw5
wpUsQpMbWtEL3iJGM55m4GDLBFx0T1kvascqh++vdzxJvvvhPziCTpG/0SBwLoFW
xS0WjQiP7L83LLGpoDyDNlfpLGOswEuZrpfK5jmzhMLSwQzLjVrAyLH7DV+jqFgi
c8ulY0HsSN3LxGCx/TTSHceh/jEhTRtULY5ssR4B/oTWDpvaJJsaIryfQRKjlnu1
pcuahWn0cMnIISUtdxTl96r/SFuJKSciq4jBUtBfb9VYLPaxlWUjlWyTiNh2+lx/
a1/ycChsPm7kUZxvwUqTQYc0EQb7m4DMWyEq8NZjXYGzmCGGF+ISQU5ky7TBjfas
vn4kk9OW0jl+a4jAhrUCNfj5qIdJ9UU7r1dka5THO3kpihWRjESDrFpqJgVRu97K
YA3MdmWYKf28okoF+c8bTAIICurQKPzoW7z3pyzu8APEucYVbxHdU4HpCgOpoNBN
Hm0zrkLH+fJ4jQbjVhIqgnhYI3t4Izt4kfey4J8rg2Q8VKYX8FRYWatSDZEchwXo
DH18M9/0gIezI/zeC3uG
=eA2q
-----END PGP SIGNATURE-----

--Sig_/7zAhT8_=abQGpq/GjFsiRCj--
