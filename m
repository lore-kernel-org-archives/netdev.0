From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH wireless-dev] adm8211: Properly initialize priv->mode in adm8211_probe
Date: Thu, 13 Jul 2006 01:43:21 -0700
Message-ID: <200607130143.33897.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1248500.Au7FSdTVaH";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:47548 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S932447AbWGMInn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 04:43:43 -0400
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1248500.Au7FSdTVaH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Properly initialize priv->mode in adm8211_probe

The adm8211 driver refuses to open without this patch. Don't know how I
ever tested the driver without this working.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/adm8211/adm8211.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wi=
reless/d80211/adm8211/adm8211.c
index 9fc5da7..4cfddf1 100644
=2D-- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -2059,6 +2059,7 @@ #endif
 	priv->tx_power =3D 0x40;
 	priv->lpf_cutoff =3D 0xFF;
 	priv->lnags_threshold =3D 0xFF;
+	priv->mode =3D IEEE80211_IF_TYPE_MGMT;
=20
 	/* Power-on issue. EEPROM won't read correctly without */
 	if (priv->revid >=3D ADM8211_REV_BA) {

--nextPart1248500.Au7FSdTVaH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEtge1T3Oqt9AH4aERAq4CAJ9uEk3cmJ8ZTXR0CbjVjAz5NfOYqgCgl+bd
ebD7+8x9dx+um7EB7/TpjNc=
=+653
-----END PGP SIGNATURE-----

--nextPart1248500.Au7FSdTVaH--
