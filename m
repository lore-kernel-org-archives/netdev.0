From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 26 Apr 2013 13:27:01 +1000
Message-ID: <20130426132701.ab5ef20e111d529c2c0ae71d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__26_Apr_2013_13_27_01_+1000_oYE6wAHH_41XQ_JS"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__26_Apr_2013_13_27_01_+1000_oYE6wAHH_41XQ_JS
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/emulex/benet/be.h between commit bc0c3405abbb
("be2net: fix a Tx stall bug caused by a specific ipv6 packet") from the
net tree and commit 0ad3157e813a ("be2net: Avoid flashing BE3 UFI on
BE3-R chip") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/ethernet/emulex/benet/be.h
index 941aa1f,e2d5ced..0000000
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@@ -435,7 -435,7 +436,8 @@@ struct be_adapter=20
  	u8 wol_cap;
  	bool wol;
  	u32 uc_macs;		/* Count of secondary UC MAC programmed */
 +	u16 qnq_vid;
+ 	u16 asic_rev;
  	u32 msg_enable;
  	int be_get_temp_freq;
  	u16 max_mcast_mac;

--Signature=_Fri__26_Apr_2013_13_27_01_+1000_oYE6wAHH_41XQ_JS
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRefQFAAoJEECxmPOUX5FEb1kP/2aSiJd/MF+96oVzca7YEnm2
REPgvJYVBHJcm78RHO1pIkgEe36BDh9MmSuzQUaOE0tfwj4OhN2OloXKD/DNLW7b
sPnw2QUY/NROkOLUSAOx1BuuOqXyLKZ60gyX8/dFxWVXcHz8jqr4+3GlvBLU9tMj
u1l72iUrj/trnP/j5QCvcJkbOpBRwp/IjqXAwo8ynzwDtcv6Ph7krhJM78ppHAwo
G9v44EpIIEY6gx9Ota9y8PKsprRQBts4k6FgzoTm/FcNMhEXPf6cgtSXSnSS36Tn
5+zPV28bSf3y/PmIolYN/QyocV3saTHfwSObZnHQOqy8v8WRwW2JfR72K7PPGES/
PrG/ne0LnnC/8g9sMJ+NgVSorY+w1geytDeBydZJWoA3lvkRLJkx5P0elEBFdT9I
26w+k2spVGbzYFa6cWls1dHlCZh84mFMDhRgCyo1gi28+llqggBy1Tm4JnPVIt06
qe6/syAJz4kgP5cOQI3zwWREtsOTerP3EJWoS4k42RciqAoj9n7TN0NcC50oYxYg
pQPjR7f7M302K4Lf53klcTcNspYCiX719tGMViHPdOfZoXXLLNYXuSfSkHNmdIFV
eJkJIImNRnnoAvhkBnNQ30u/FEBX8FkU99RgzDHa1ioHYx4GZr2St/M2T7rYEiix
8SRUqO1j8z8J35NS2xzo
=kPcb
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Apr_2013_13_27_01_+1000_oYE6wAHH_41XQ_JS--
