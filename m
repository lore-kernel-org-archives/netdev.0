From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 10 Apr 2015 13:12:58 +1000
Message-ID: <20150410131258.04416c49@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/WFl1ec3WXBVP6_UB2LnHH8_"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Phil Reid <preid@electromag.com.au>,
	Dinh Nguyen <dinguyen@opensource.altera.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/WFl1ec3WXBVP6_UB2LnHH8_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c between commit
27015f8c1757 ("stmmac: devm_reset_control_get can return PROBE_DEFER")
from the net tree and commit cbe21d92e4d5 ("net: stmmac: make reset
control an optional requirement") from the net-next tree.

I fixed it up (I just used the net-next version) and can carry the fix
as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/WFl1ec3WXBVP6_UB2LnHH8_
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVJz++AAoJEMDTa8Ir7ZwVQEkP/3gtKck9Onw8JfxoxOLre7kX
EaF+BnrzpREMZjS/cF2qr7Ey/XDCco3XI+z8xLeeL/vh91GGDWpPa025oR4a+g/7
wtkft8N2AieUjnjsP/VxiHRVatC8y7fbwFDpOp5mXHz1+xOis73YPCJoeAAzL4i/
MAZ87yaCVp3kbDFzCIYC9eGmIR7esC7KgdPi+8BDmWAZCBhRf3CGSiyYqg+J4ux7
k9AGIIwZjJYl1xb0vp7/Jv58+TUzNag4vh+OfCN3WmQttfyCPd2F9Dgr3dmAjLbS
SBpUq2tt5phgnmDMnySX4GCjPLfP06YaJOLTz3ozolyxMcni11mB6rLYGf7kS8K1
JfqjDAkHHTLDIcm2ZSb7w6BbQLsKJ1UN6Ii9M1LUsQ9hUaoqAYyF+El77YptZbwP
y4kScEHFZ44a2TK1T7K+81yzHMTY66y2dvcFASwmFjmCW0WHYdvLGIulzdzQ4M0t
Jb+FMrpPzj0U3gCcd2DefTjRv+4yQS8JlxV7FBWGE8RvpCmTAXu1cKTwhjaKdBsr
pUHm1bpRYHxjRMqbMxDGZjfqL0Z2IN3ojO3BVSmoWjjxslGyxpKgEzlF/uTTHa1Y
puZtKmKjr4pZJUMwAxRB3vr+ZiCNPkeb6JAarhh31PZKnbJf1fi/8j9XV9J+WZ5o
ajv2gHayp86ojeZe/jJP
=NH44
-----END PGP SIGNATURE-----

--Sig_/WFl1ec3WXBVP6_UB2LnHH8_--
