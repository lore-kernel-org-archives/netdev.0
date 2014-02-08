From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH] net: vxge: Remove unused device pointer
Date: Sun, 9 Feb 2014 00:16:17 +0100
Message-ID: <20140209001617.1d1543d4@spike>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/1vaYR0v=1Ha6835zRnj3KaF"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jingoo Han <jg1.han@samsung.com>,
	Masanari Iida <standby24x7@gmail.com>,
	John Stultz <john.stultz@linaro.org>,
	dingtianhong <dingtianhong@huawei.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:49608 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbaBHXQT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Feb 2014 18:16:19 -0500
Received: from spike ([81.217.122.98]) by mail.gmx.com (mrgmx002) with ESMTPSA
 (Nemesis) id 0M3zne-1VKrCM2BJC-00rZtJ for <netdev@vger.kernel.org>; Sun, 09
 Feb 2014 00:16:18 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/1vaYR0v=1Ha6835zRnj3KaF
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Remove occurrences of unused struct __vxge_hw_device pointer in functions
vxge_learn_mac() and vxge_rem_isr().

Detected by Coverity: CID 139839, CID 139842.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/e=
thernet/neterion/vxge/vxge-main.c
index 1ded50ca..e46e869 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -726,9 +726,6 @@ static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac=
_header)
 	int vpath_idx =3D 0;
 	enum vxge_hw_status status =3D VXGE_HW_OK;
 	struct vxge_vpath *vpath =3D NULL;
-	struct __vxge_hw_device *hldev;
-
-	hldev =3D pci_get_drvdata(vdev->pdev);
=20
 	mac_address =3D (u8 *)&mac_addr;
 	memcpy(mac_address, mac_header, ETH_ALEN);
@@ -2443,9 +2440,6 @@ static void vxge_rem_msix_isr(struct vxgedev *vdev)
=20
 static void vxge_rem_isr(struct vxgedev *vdev)
 {
-	struct __vxge_hw_device *hldev;
-	hldev =3D pci_get_drvdata(vdev->pdev);
-
 #ifdef CONFIG_PCI_MSI
 	if (vdev->config.intr_type =3D=3D MSI_X) {
 		vxge_rem_msix_isr(vdev);
--=20
1.8.3.2

--Sig_/1vaYR0v=1Ha6835zRnj3KaF
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJS9rrBAAoJEKssnEpaPQKEszcQANLCrMb5qqjz3929PT3p+8t7
rDP2wbeVYHx+ewbZqS0xCxhB0+gbFE8Hcyn1jJLquZFgQysvrzGKXsMde5VTCjAW
TxivrWvoiIEqxkHn4tKEn/g1ib3QjEebniwuXzB5eNXtTk4EEUTAR5XCBac2soab
5Ux2WQp5DizQQAO5g8fr4J4GlNBOwyqgvzaHY4QRlUFw5l/rv6xR1RK2wzHGFOon
Tz1ZxaPLuh1lS2BYL0TT10AVe9Lsxzy4bZ5j6uWBiYpv59dMR4bu5wGxKStvKEii
8pwwKpYSNf+Ea9n1M8nOESd8GgyQKZG6JKvFqUZUY4L+DEVHIP0YQ4suwAFzxAXx
WbfTJ2qFk4oBbOuEuhip+owy8JZ7FxjDoyZFRJBqPltm+WLhnUX1eRztDUSWZ0oF
3wftJKUdZfwZOhl4TJx3zgDZaTGxqAMyk+BlzWRPySVJzYpWIu9kaJoCur6XCP8S
2vR9iu7xWqvszdnyP96Bquol6ENj1nr9H6RfeoukPiAl6rniHWDfEq8+dLxJWo3z
/CwjSXW3ipce1oqkSxizoo0kH3KFRRU2caH06qM2qaO9myJ/M4waxdMSFugsbLQl
Gm2x3AkbchDphTbhQzE7Z7hAREBNj9G0fPeduYX3VEV0nqnWwFTwvZ9BEp124zgT
Ui9fhxNlo7AMw7rK7udy
=KJ1F
-----END PGP SIGNATURE-----

--Sig_/1vaYR0v=1Ha6835zRnj3KaF--
