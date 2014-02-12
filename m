From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 10/14] ethtool: Expand documentation of struct
 ethtool_stats
Date: Wed, 12 Feb 2014 22:14:43 +0000
Message-ID: <1392243283.15615.14.camel@deadeye.wl.decadent.org.uk>
References: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wUIGrMqBkOms89NSRR6d"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52804 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753999AbaBLWOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 17:14:50 -0500
In-Reply-To: <1392243184.15615.4.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wUIGrMqBkOms89NSRR6d
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/uapi/linux/ethtool.h | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index f246f37..e96aec0 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -597,10 +597,20 @@ struct ethtool_test {
 	__u64	data[0];
 };
=20
-/* for dumping NIC-specific statistics */
+/**
+ * struct ethtool_stats - device-specific statistics
+ * @cmd: Command number =3D %ETHTOOL_GSTATS
+ * @n_stats: On return, the number of statistics
+ * @data: Array of statistics
+ *
+ * Users must use %ETHTOOL_GSSET_INFO or %ETHTOOL_GDRVINFO to find the
+ * number of statistics that will be returned.  They must allocate a
+ * buffer of the appropriate size (8 * number of statistics)
+ * immediately following this structure.
+ */
 struct ethtool_stats {
-	__u32	cmd;		/* ETHTOOL_GSTATS */
-	__u32	n_stats;	/* number of u64's being returned */
+	__u32	cmd;
+	__u32	n_stats;
 	__u64	data[0];
 };
=20


--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-wUIGrMqBkOms89NSRR6d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvvyU+e/yOyVhhEJAQqhixAA0ZkFVjXPvzdWkyPvW4j55lWDAIaBnjGD
n1w6l/RLgi9E8g738S1pXXjKwbmodIEyviJ6qmtuSZl1S0CH4aIEYXb5aOqZGd+x
1aq3tBRMBcF7Gt2xXKahnjKn+zDlm5m2f3MshlHIclaFpVDhOCj4IUvR6xbbEV5P
MMQtog4b2xlLAxATL/VhpxKuwMY+KKYjZXl8qKncwvuc2X41sy7Lgvz2UET2VXli
vipyjRAazBVros0ItPO2xVMs0wyaOqRsLeOK6H98VIqA2y05K3janPP2wsjbOLW4
EfGyC1rCCnz2Q50Qzb5Qi3mR/3vrjXmd7UfSe7tJjJkqqrjdeL5py8wy+riNOHRD
hbVJ6w2UTDkfKSaijW4Jfpy4O0H3+3oCyJzkW59c/m3ukpOsO7z8Jj+aFlvpavws
IYbirr6NVeN3vKbSZKGuYf+cfG1iy5YyHiZdRpy0tTAg/+9kmOzb4P1BQFuZYYKl
vyU0NeiQlAKPf7z5Ew+z78ydCGf5N3yJmy6F0p8EgNw858AE4pKemzAh7NAxqDSp
W6fBf30yp+rIew4DlTzAXH3FtOeL/IIfgHFIpyWsAEhk7k1cwRr9pimEDehgD7uY
qxwM63R7/ogiyCjwTjBTYPpf1Kzf7daTEYD64MavPypWuBdj50HgZ7wzYZe8xGRH
NMZ54kZnXyI=
=9GwS
-----END PGP SIGNATURE-----

--=-wUIGrMqBkOms89NSRR6d--
