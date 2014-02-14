From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the devicetree tree with the net-next
 tree
Date: Fri, 14 Feb 2014 14:16:39 +1100
Message-ID: <20140214141639.74ea45728f39a8ee874ce986@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__14_Feb_2014_14_16_39_+1100_sjO5N6.pESqgo9wY"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__14_Feb_2014_14_16_39_+1100_sjO5N6.pESqgo9wY
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Grant,

Today's linux-next merge of the devicetree tree got a conflict in
drivers/of/of_net.c between commit 8a2fe56e8827 ("net: phy: re-design
phy_modes to be self-contained") from the net-next tree and commit
cf4c9eb5a451 ("of: make of_get_phy_mode parse 'phy-connection-type'")
from the devicetree tree.

I fixed it up (I applied the following merge fix patch) and can carry the
fix as necessary (no action is required).

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 14 Feb 2014 14:14:31 +1100
Subject: [PATCH] net: of: merges fix for a moved comment

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/linux/phy.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 42f1bc7eaeb0..bc77c174e0a3 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -79,8 +79,8 @@ typedef enum {
=20
 /**
  * It maps 'enum phy_interface_t' found in include/linux/phy.h
- * into the device tree binding of 'phy-mode', so that Ethernet
- * device driver can get phy interface from device tree.
+ * into the device tree binding of 'phy-mode' or 'phy-connection-type',
+ * so that Ethernet device driver can get phy interface from device tree.
  */
 static inline const char *phy_modes(phy_interface_t interface)
 {
--=20
1.9.0.rc3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__14_Feb_2014_14_16_39_+1100_sjO5N6.pESqgo9wY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS/YqcAAoJEMDTa8Ir7ZwV7ZEQAIHF/EtycQCpIQV297/Ksqgk
e6C6vJhT+lX/2/2BPbA370X/eeWqB8ceHiwvbgVGwB95mTkw+Q8D9blSPZn6/5CI
OkuQsLjkqHGO5EwUtbllcHaFU4iUZXI6o2Jz+V7up/WY6UYuPi+8E6Lm2+3wzlWq
nys63I+BJTU7UXFpOKDcF34WZw+Dbcqxx6RfUbTJAUbi5x5R/GKAq5sNNiVdffm6
tyZvWrrpSIoezgLkjHPo99ZeOLNPDqHpKduc4cxwRxZArdAwmuUkaGRAgi0Aj8SY
SH6crWxCpoYuAl6RyhsceMjxz1FLPaS3WzPu2sozng+SxJ+tCt5NmsT3hlg3TMH1
/NcNL8h0khZW8j2TvbTQR4nIZ2z6CYutKTrzwiuk4jI+DoY5/dz6tbIeuGdHIAuG
CyvNfIrQDklCl2V5TF5yMNynlEKak6g3tOoNl0sWLDM++Z2LUo8N3N+mvwcKbhul
jUK0kB3noTGGaVzwHDthgFSm9Kn9TQH6gpvLB2VAC7H0wL4LGYSNE+mEcd670pNB
ftzQm+6lmn2hteQ4sNPphNRE7OsQlFqSRqdJivV3h3jD5ngvJqwtxO1jkMxWXKFl
lJzNahReCtQLdJwlabNG73QK7iQPhLdl2gYLMl0GiaH8ln3h38qX2IisDrGVrsBc
S68f0QoY+SFvG6IuyR3C
=aTXQ
-----END PGP SIGNATURE-----

--Signature=_Fri__14_Feb_2014_14_16_39_+1100_sjO5N6.pESqgo9wY--
