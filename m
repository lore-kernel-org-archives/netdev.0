From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 12 Feb 2013 11:57:33 +1100
Message-ID: <20130212115733.1205c57d893aa3f16fc83526@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__12_Feb_2013_11_57_33_+1100_BWEO+_NF9FRce+D8"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yuval Mintz <yuvalmin@broadcom.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__12_Feb_2013_11_57_33_+1100_BWEO+_NF9FRce+D8
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c between commit
0aba93e2b9fb ("bnx2x: set gso_type") from the net tree and commit
cbf1de72324a ("bnx2x: fix GRO parameters") from the net-next tree.

I fixed it up (since the former commit says that the latter is the more
complex fix, I just used that) and can carry the fix as necessary (no
action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__12_Feb_2013_11_57_33_+1100_BWEO+_NF9FRce+D8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRGZN9AAoJEECxmPOUX5FELpoQAKdiylGo4xgYSVFWa2aEi2mX
MYFezta7OCJA1XGrbR3Wy/bH3QDI1k9bZVR10o9Hm9oNYj8x1ks3y8iGQNlQYiHw
sQCPm/GVDEfy4pKHjoaNYZvGWBTUokj+ZME/0dXjlqcpav4Ew8O7E8B2bQIJiAL5
0B/jsk6DbQ5bKn9a6L2IZj2rV1g7V2UJX8TGISmzkm0XcbOqElgkfpzj4M3zE3rU
1OzK4HWe+PIQzfeCCNBkM1jRy8niZZTghSXFqJv3sOantR6xEBruifq+lfdDhEUa
naNg6vSgDrjp8ovElOcI86jev/ba3WcjKWyOZSdcMzy7yPXGO+n3ucW0vnlhw/uX
4ZD3Wkeu0MyIeHijg7OgQ6+D7uiBYcoTo57jgdl48vXPbDSD5mxXJMKsvFsnhhZF
9SxtcLUyM+jiPTvuF4Bt5Nf/tKHz2MuyampR+36l/22My207l9BMnMc/+A7ttdPo
H+bvmH1/kO7/OhNItiSNwft1z5aJODCCVDnrMb88qieu529Htc1z065lodo4g01g
Fgjn3hWrKYJVmHgWnhT5lL8612cu9N7gIAXpwpJiSpWyXKEQHKmYMacJAboE9Jp/
zFXLuWt3Sq3cOzCkrbFkAUrNyoqkIuQTw3QmMT+mgeGlVLIt4fv7daBMWH222J6m
Mf+7yeKbXwUfkegP5Nf+
=ODnF
-----END PGP SIGNATURE-----

--Signature=_Tue__12_Feb_2013_11_57_33_+1100_BWEO+_NF9FRce+D8--
