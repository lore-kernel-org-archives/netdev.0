From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next] bcm87xx: Add MODULE_DEVICE_TABLE
Date: Sun, 01 Sep 2013 22:33:04 +0100
Message-ID: <1378071184.25743.52.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-cOYSjxHXdn2xJi6NdXfo"
Cc: David Daney <david.daney@cavium.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60093 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753071Ab3IAVdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 17:33:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-cOYSjxHXdn2xJi6NdXfo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

bcm87xx currently isn't auto-loaded if built as a module.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Compile-tested only.

Ben.

 drivers/net/phy/bcm87xx.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
index 7997895..f5b44ff 100644
--- a/drivers/net/phy/bcm87xx.c
+++ b/drivers/net/phy/bcm87xx.c
@@ -230,4 +230,11 @@ static void __exit bcm87xx_exit(void)
 }
 module_exit(bcm87xx_exit);
=20
+static struct mdio_device_id __maybe_unused bcm87xx_tbl[] =3D {
+	{ PHY_ID_BCM8706, 0xffffffff },
+	{ PHY_ID_BCM8727, 0xffffffff },
+	{ }
+};
+
 MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(mdio, bcm87xx_tbl);


--=-cOYSjxHXdn2xJi6NdXfo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIVAwUAUiOykOe/yOyVhhEJAQrIcA/+MECuiQKDOTIMuVFavssHeukuG3TPOflb
PM3CjxP4t7EfJVohtavXmykJE7DIDRraUNf2tVGvlxQUpIjrA2vOmV5AhZfGmSkr
BOuE391SHvy9q25UmwA/OGfKuryQwI2ogzlchKQg3Xj+9uHtAQf2yqQTduqaC8Dz
3FhaCbHpL9Vh9hwi886lDFemV2uvUyH3Ij9lRE1xTGnWyzhl8X1V2vRmicikNeqs
lO3AbzjuC8jHAnfQke/M+BqV6zbrTmUCMI188DVaNH9MkBgMjwSwZnjFHUhOvNWs
9rrPcM+a645g8IdKr1+/vDLVMoKdxieE9Da0QODJ0NaNeXTmiuHDTU95TbcBfpu8
GOEITVSXj3yziCeXSY+PusjFq68OgGA2pL2PAV65QvgeRbzYuTusjnKgWxu9tXOp
/vlrYZuO/202rJeE4k9YiQ+f3E9YhnpS+7rBabZPNh/NrwRSDM7OVVtEC3+tG4Dt
yee5iWXL5lFvM6E8odobEh92e6Hnz292Y2TSd4ZwWbn9+TFPnvJ+98W21Xie5B9R
pvn4iykOYj2+getUO4drwwj+GU2gehXtGa+srBKLeY3xtD5GKOa2mbdEbZczwKGx
v93TII1FpKXtsmJjw2z4sC/NU/qzbRGX2ZmuR8wfdNUQZU7lTty7JiqQaQ7UND/G
L7CE+CstXgU=
=eUJX
-----END PGP SIGNATURE-----

--=-cOYSjxHXdn2xJi6NdXfo--
